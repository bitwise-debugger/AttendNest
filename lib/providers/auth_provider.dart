import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = true; // Initially true while we check auth state
  bool _isAuthActionLoading = false; // For login/register button states
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthActionLoading => _isAuthActionLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.authStateChanges.listen((User? firebaseUser) async {
      _isLoading = true;
      notifyListeners();

      if (firebaseUser != null) {
        _currentUser = await _authService.getUserData(firebaseUser.uid);
      } else {
        _currentUser = null;
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  void _setLoading(bool value) {
    _isAuthActionLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      UserModel? user = await _authService.login(email, password);
      _setLoading(false);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  Future<bool> registerStudent({
    required String fullName,
    required String rollNumber,
    required String department,
    required String semester,
    String? roomNumber,
    String? hostelBlock,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      UserModel? user = await _authService.registerStudent(
        fullName: fullName,
        rollNumber: rollNumber,
        department: department,
        semester: semester,
        roomNumber: roomNumber,
        hostelBlock: hostelBlock,
        email: email,
        password: password,
      );
      _setLoading(false);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Registration failed. Please check your details and try again.');
      return false;
    }
  }

  Future<bool> registerAdmin({
    required String fullName,
    required String employeeId,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      UserModel? user = await _authService.registerAdmin(
        fullName: fullName,
        employeeId: employeeId,
        email: email,
        password: password,
      );
      _setLoading(false);
      if (user != null) {
        _currentUser = user;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Registration failed. Please try again later.');
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Could not send reset email. Please try again.');
      return false;
    }
  }

  Future<bool> updateProfile(UserModel user) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.updateProfile(user);
      _currentUser = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update profile. Please check your connection.');
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    _setLoading(true);
    _setError(null);
    try {
      await _authService.updatePassword(newPassword);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to update password. Please try again.');
      return false;
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'requires-recent-login':
        return 'This action requires a recent login. Please log in again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
