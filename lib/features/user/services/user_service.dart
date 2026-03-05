import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile_model.dart';

/// Simple Firestore-backed service for reading/updating user profile data.
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  Future<UserProfileModel?> getCurrentProfile() async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserProfileModel.fromMap(uid, doc.data()!);
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    final uid = _uid;
    if (uid == null) throw Exception('Not authenticated');
    await _firestore.collection('users').doc(uid).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
  }
}
