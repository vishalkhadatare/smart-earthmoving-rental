import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import '../models/account_type.dart';
import '../models/app_user_model.dart';

enum AuthState { splash, onboarding, login, signup, authenticated }

/// Provider to manage authentication state with Firebase
class AuthProvider extends ChangeNotifier {
  // Configure your dynamic link domain for in-app email verification handling.
  // Replace with your Firebase Dynamic Links domain (e.g. https://yourapp.page.link)
  static const String dynamicLinkDomain = 'https://yourapp.page.link';
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

  String? _cachedPhone;

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

  String? get userPhone => _cachedPhone;

  Future<void> loadUserProfile() async {
    await _ensureFirebaseInitialized();
    final uid = _firebaseAuth.currentUser?.uid;
    if (uid == null) return;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      _cachedPhone = doc.data()?['phone'] as String?;
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateUserProfile({
    String? name,
    String? phone,
    File? photoFile,
  }) async {
    await _ensureFirebaseInitialized();
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    try {
      String? newPhotoUrl;
      if (photoFile != null) {
        final ref = FirebaseStorage.instance.ref(
          'profile_pictures/${user.uid}.jpg',
        );
        await ref.putFile(photoFile);
        newPhotoUrl = await ref.getDownloadURL();
        await user.updatePhotoURL(newPhotoUrl);
      }
      if (name != null && name.trim().isNotEmpty) {
        await user.updateDisplayName(name.trim());
      }
      final updateData = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (phone != null) updateData['phone'] = phone.trim();
      if (newPhotoUrl != null) updateData['photoUrl'] = newPhotoUrl;
      if (updateData.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(updateData, SetOptions(merge: true));
      }
      if (phone != null) _cachedPhone = phone.trim();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profile update failed: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  bool get isAuthenticated => _state == AuthState.authenticated;

  bool get isEmailVerified =>
      __firebaseAuth?.currentUser?.emailVerified ?? false;

  Future<void> sendEmailVerification() async {
    await _ensureFirebaseInitialized();
    final user = _firebaseAuth.currentUser;
    if (user == null || user.emailVerified) return;
    await user.sendEmailVerification();
  }

  Future<void> refreshEmailVerificationStatus() async {
    await _ensureFirebaseInitialized();
    await _firebaseAuth.currentUser?.reload();
    notifyListeners();
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
        await _loadCurrentAccountType(_firebaseAuth.currentUser!.uid);
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
        // Send email verification with deep link settings so user can return to app
        try {
          await createdUser.sendEmailVerification(ActionCodeSettings(
            url: '$dynamicLinkDomain/verify?uid=${createdUser.uid}',
            handleCodeInApp: true,
          ));
        } catch (_) {}
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

      // Obtain auth details (no artificial timeout — let the platform handle it)
      final googleAuth = await googleUser.authentication;

      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      await _loadCurrentAccountType(userCredential.user?.uid);

      _currentUser = userCredential.user?.email ?? googleUser.email;
      _state = AuthState.authenticated;
      _isLoading = false;
      _isGoogleLoading = false;
      notifyListeners();
      return true;
    } on TimeoutException {
      // Should no longer happen, but handle gracefully just in case
      _cachedGoogleUser = null;
      _errorMessage =
          'Connection timed out. Please check your internet and try again.';
      _isLoading = false;
      _isGoogleLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _cachedGoogleUser = null;
      _errorMessage = 'Google sign in failed. Please try again.';
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

  /// Phone login is not available.
  Future<bool> signInWithPhone({required String phoneNumber}) async {
    _errorMessage = 'Phone login is not available.';
    notifyListeners();
    return false;
  }

  /// Phone OTP verification is not available.
  Future<bool> verifyOTP({required String otp}) async {
    _errorMessage = 'Phone verification is not available.';
    notifyListeners();
    return false;
  }

  /// Resend OTP (sends a fresh token via Appwrite).
  Future<bool> resendOTP({required String phoneNumber}) async {
    return signInWithPhone(phoneNumber: phoneNumber);
  }

  /// Reset phone auth state.
  void resetPhoneAuth() {
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
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);

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

    final userDoc = await _firestore.collection('users').doc(uid).get();
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
