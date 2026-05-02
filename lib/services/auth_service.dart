import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Login
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        return await getUserData(credential.user!.uid);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Register Student
  Future<UserModel?> registerStudent({
    required String fullName,
    required String rollNumber,
    required String department,
    required String semester,
    String? roomNumber,
    String? hostelBlock,
    required String email,
    required String password,
  }) async {
    try {
      // Create auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        String uid = credential.user!.uid;

        UserModel newUser = UserModel(
          uid: uid,
          fullName: fullName,
          rollNumber: rollNumber,
          department: department,
          semester: semester,
          roomNumber: roomNumber,
          hostelBlock: hostelBlock,
          email: email,
          role: 'student', // Admin creation is not in MVP scope via UI
        );

        // Save to Firestore
        await _firestore.collection('users').doc(uid).set(newUser.toMap());

        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Register Admin
  Future<UserModel?> registerAdmin({
    required String fullName,
    required String employeeId,
    required String email,
    required String password,
  }) async {
    try {
      // Create auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        String uid = credential.user!.uid;

        UserModel newUser = UserModel(
          uid: uid,
          fullName: fullName,
          employeeId: employeeId,
          email: email,
          role: 'admin',
        );

        // Save to Firestore
        await _firestore.collection('users').doc(uid).set(newUser.toMap());

        return newUser;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Update Profile
  Future<void> updateProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Update Password
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
