import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/account_type.dart';
import '../models/app_user_model.dart';

enum AuthState { splash, onboarding, login, signup, authenticated }

/// Provider to manage authentication state with Firebase
class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.splash;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _preferOtpLoginMode = false;
  String? _currentUser;
  String? _errorMessage;
  String? _verificationId;
  bool _isOtpSent = false;
  AccountType? _currentAccountType;

  FirebaseAuth? __firebaseAuth;
  FirebaseFirestore? __firestore;
  GoogleSignIn? __googleSignIn;

  FirebaseAuth get _firebaseAuth => __firebaseAuth!;
  FirebaseFirestore get _firestore => __firestore!;
  GoogleSignIn get _googleSignIn => __googleSignIn!;

  GoogleSignInAccount? _cachedGoogleUser;

  AuthState get state => _state;
  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  String? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isOtpSent => _isOtpSent;
  String? get verificationId => _verificationId;
  AccountType? get currentAccountType => _currentAccountType;
  String get userName {
    final displayName = __firebaseAuth?.currentUser?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final email = __firebaseAuth?.currentUser?.email ?? _currentUser;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'User';
  }

  String get userEmail =>
      __firebaseAuth?.currentUser?.email ?? _currentUser ?? 'Not available';

  String? get userPhotoUrl => __firebaseAuth?.currentUser?.photoURL;

  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Update basic account information (name, email, photo URL, phone).  
  /// Caller is responsible for any OTP/phone verification.
  Future<bool> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
    String? phone,
  }) async {
    await _ensureFirebaseInitialized();
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dynamic user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('User not signed in');

      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name);
        _currentUser = name;
      }
      if (email != null && email.isNotEmpty && email != user.email) {
        await user.updateEmail(email);
        _currentUser = email;
      }
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await user.updatePhotoURL(photoUrl);
      }
      if (phone != null && phone.isNotEmpty) {
        // phone update should be handled externally via verification
        // simply save to firestore below
      }

      // update firestore record as well
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (photoUrl != null) data['photoUrl'] = photoUrl;
      if (phone != null) data['mobileNumber'] = phone;

      if (data.isNotEmpty && user.uid.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(data, SetOptions(merge: true));
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profile update failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool consumePreferOtpLoginMode() {
    final shouldPreferOtpMode = _preferOtpLoginMode;
    _preferOtpLoginMode = false;
    return shouldPreferOtpMode;
  }

  Future<void> _ensureFirebaseInitialized() async {
    if (__firebaseAuth != null &&
        __firestore != null &&
        __googleSignIn != null) {
      return;
    }

    // Firebase.initializeApp() is already called in main(), so just grab instances
    __firebaseAuth = FirebaseAuth.instance;
    __firestore = FirebaseFirestore.instance;
    __googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      signInOption: SignInOption.standard,
    );
  }

  /// Initialize auth state (check if user was previously logged in)
  Future<void> initialize() async {
    try {
      await _ensureFirebaseInitialized();

      // If already signed in, skip onboarding and go straight to app
      if (_firebaseAuth.currentUser != null) {
        _currentUser = _firebaseAuth.currentUser?.email;
        await _loadCurrentAccountType(_firebaseAuth.currentUser!.uid).timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            _currentAccountType = AccountType.user;
          },
        );
        _currentAccountType ??= AccountType.user;
        _state = AuthState.authenticated;
        _isLoading = false;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('Auth init error: $e');
    }

    _state = AuthState.onboarding;
    notifyListeners();
  }

  /// Sign up with email and password using Firebase
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required AccountType accountType,
  }) async {
    await _ensureFirebaseInitialized();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Create user in Firebase with timeout
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Sign up took too long. Please try again.');
            },
          );

      // Update user profile with name
      await userCredential.user
          ?.updateDisplayName(name)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Profile update took too long');
            },
          );

      final createdUser = userCredential.user;
      if (createdUser != null) {
        final appUser = AppUserModel(
          id: createdUser.uid,
          name: name,
          email: email,
          accountType: accountType,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(createdUser.uid)
            .set(appUser.toMap(), SetOptions(merge: true));
      }

      _currentUser = email;
      _currentAccountType = accountType;
      _state = AuthState.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Sign up failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign in with email and password using Firebase
  Future<bool> signIn({required String email, required String password}) async {
    await _ensureFirebaseInitialized();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Sign in took too long. Please try again.');
            },
          );

      await _loadCurrentAccountType(userCredential.user?.uid);

      _currentUser = email;
      _state = AuthState.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Sign in failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email
  Future<bool> resetPassword({required String email}) async {
    await _ensureFirebaseInitialized();

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseAuth
          .sendPasswordResetEmail(email: email)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception(
                'Password reset request took too long. Please try again.',
              );
            },
          );

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getFirebaseErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Password reset failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Proceed past onboarding
  void completeOnboarding() {
    _state = AuthState.login;
    notifyListeners();
  }

  /// Switch to signup
  void goToSignUp() {
    _preferOtpLoginMode = false;
    _state = AuthState.signup;
    notifyListeners();
  }

  /// Switch to login
  void goToLogin({bool preferOtpMode = false}) {
    _preferOtpLoginMode = preferOtpMode;
    _state = AuthState.login;
    notifyListeners();
  }

  /// Switch to onboarding
  void goToOnboarding() {
    _preferOtpLoginMode = false;
    _state = AuthState.onboarding;
    notifyListeners();
  }

  /// Sign in with Google using Firebase
  Future<bool> signInWithGoogle() async {
    await _ensureFirebaseInitialized();

    _isLoading = true;
    _isGoogleLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if already have a cached Google user
      GoogleSignInAccount? googleUser =
          _cachedGoogleUser ?? await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        _isLoading = false;
        _isGoogleLoading = false;
        _cachedGoogleUser = null;
        notifyListeners();
        return false;
      }

      _cachedGoogleUser = googleUser;

      // Obtain auth details with timeout
      final googleAuth = await googleUser.authentication.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Google authentication took too long');
        },
      );

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase with timeout
      final userCredential = await _firebaseAuth
          .signInWithCredential(credential)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Firebase sign in took too long');
            },
          );

      await _loadCurrentAccountType(userCredential.user?.uid);

      _currentUser = userCredential.user?.email ?? googleUser.email;
      _state = AuthState.authenticated;
      _isLoading = false;
      _isGoogleLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _cachedGoogleUser = null;
      _errorMessage = 'Google sign in failed: ${e.toString()}';
      _isLoading = false;
      _isGoogleLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with Google using Firebase
  Future<bool> signUpWithGoogle() async {
    return signInWithGoogle(); // Same flow as sign in for Google
  }

  /// Sign in with Phone OTP - Send OTP to phone number
  Future<bool> signInWithPhone({required String phoneNumber}) async {
    await _ensureFirebaseInitialized();

    _isLoading = true;
    _errorMessage = null;
    _isOtpSent = false;
    notifyListeners();

    try {
      // Validate phone number format
      if (!phoneNumber.startsWith('+')) {
        _errorMessage =
            'Please enter phone number with country code (e.g., +1234567890)';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-sign in if credential is automatically verified
          await _firebaseAuth.signInWithCredential(credential);
          _currentUser = phoneNumber;
          _state = AuthState.authenticated;
          _isOtpSent = false;
          _isLoading = false;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _errorMessage = _getPhoneAuthErrorMessage(e.code);
          _isOtpSent = false;
          _isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _isOtpSent = true;
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          _isLoading = false;
          notifyListeners();
        },
      );
      return true;
    } catch (e) {
      _errorMessage = 'Phone verification failed: ${e.toString()}';
      _isOtpSent = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify OTP code
  Future<bool> verifyOTP({required String otp}) async {
    await _ensureFirebaseInitialized();

    if (_verificationId == null) {
      _errorMessage = 'Verification session expired. Please try again.';
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      _currentUser = userCredential.user?.phoneNumber;
      _state = AuthState.authenticated;
      _isOtpSent = false;
      _verificationId = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getPhoneAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'OTP verification failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Resend OTP
  Future<bool> resendOTP({required String phoneNumber}) async {
    return signInWithPhone(phoneNumber: phoneNumber);
  }

  /// Reset phone auth state
  void resetPhoneAuth() {
    _verificationId = null;
    _isOtpSent = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _ensureFirebaseInitialized();

    _isLoading = true;
    _cachedGoogleUser = null;
    notifyListeners();

    try {
      // Sign out from both Firebase and Google in parallel
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Sign out took too long');
        },
      );

      _currentUser = null;
      _currentAccountType = null;
      _state = AuthState.onboarding;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Sign out failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCurrentAccountType(String? uid) async {
    if (uid == null) {
      _currentAccountType = null;
      return;
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(const Duration(seconds: 2));
    final accountTypeValue = userDoc.data()?['accountType'] as String?;

    switch (accountTypeValue) {
      case 'owner':
        _currentAccountType = AccountType.owner;
        break;
      case 'user':
        _currentAccountType = AccountType.user;
        break;
      default:
        _currentAccountType = null;
    }
  }

  /// Convert Firebase phone auth error codes to user-friendly messages
  String _getPhoneAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format.';
      case 'missing-phone-number':
        return 'Phone number is required.';
      case 'quota-exceeded':
        return 'Too many requests. Please try again later.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'operation-not-allowed':
        return 'Phone sign-in is not enabled.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'session-expired':
        return 'Verification session expired. Please request a new code.';
      default:
        return 'Phone verification failed: $code';
    }
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getFirebaseErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check and try again.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'wrong-password':
        return 'Email or password is incorrect.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
