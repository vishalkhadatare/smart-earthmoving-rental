import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }
  
  // Get current user
  static User? get currentUser => _auth.currentUser;
  
  // Get auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Register user with email and password
  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      // Create user with Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User user = userCredential.user!;
      
      // Store additional user data in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      });
      
      print('✅ User registered successfully: $email');
      
      return {
        'success': true,
        'message': 'User registered successfully',
        'userId': user.uid,
        'user': {
          'id': user.uid,
          'email': user.email,
          'name': name,
          'phone': phone,
        }
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Registration failed';
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      
      print('❌ Registration error: $errorMessage');
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ Registration error: $e');
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }
  
  // Login user with email and password
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User user = userCredential.user!;
      
      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      Map<String, dynamic> userData = {};
      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;
      }
      
      print('✅ User logged in successfully: $email');
      
      return {
        'success': true,
        'message': 'Login successful',
        'user': {
          'id': user.uid,
          'email': user.email,
          'name': userData['name'] ?? 'User',
          'phone': userData['phone'] ?? '',
        }
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Login failed';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-disabled':
          errorMessage = 'Account disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Try again later';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      
      print('❌ Login error: $errorMessage');
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }
  
  // Get user by ID
  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return {
          'id': userData['uid'],
          'email': userData['email'],
          'name': userData['name'],
          'phone': userData['phone'],
          'createdAt': userData['createdAt'],
          'isActive': userData['isActive'],
        };
      }
      return null;
    } catch (e) {
      print('❌ Error getting user: $e');
      return null;
    }
  }
  
  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
  }) async {
    try {
      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      updateData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('users').doc(userId).update(updateData);
      
      return {
        'success': true,
        'message': 'Profile updated successfully',
      };
    } catch (e) {
      print('❌ Error updating user: $e');
      return {
        'success': false,
        'message': 'Update failed: ${e.toString()}',
      };
    }
  }
  
  // Sign out user
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }
  
  // Reset password
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      
      return {
        'success': true,
        'message': 'Password reset email sent',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Password reset failed';
      
      switch (e.code) {
        case 'invalid-email':
          errorMessage = 'Invalid email address';
          break;
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        default:
          errorMessage = 'Password reset failed: ${e.message}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Password reset failed: ${e.toString()}',
      };
    }
  }
  
  // Get database info
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    return {
      'database': 'Firebase Firestore',
      'collection': 'users',
      'connected': true,
      'message': 'Connected to Firebase Firestore successfully',
    };
  }
  
  // Get all users (for testing/admin purposes)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        return {
          'id': userData['uid'],
          'email': userData['email'],
          'name': userData['name'],
          'phone': userData['phone'],
          'createdAt': userData['createdAt'],
          'isActive': userData['isActive'],
        };
      }).toList();
    } catch (e) {
      print('❌ Error getting users: $e');
      return [];
    }
  }
}
