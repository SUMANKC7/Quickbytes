import 'package:QuickBites/screen/user/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser != null) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists) {
          _user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        } else {
          // Handle case where user document doesn't exist
          print('User document does not exist for UID: ${firebaseUser.uid}');
          _user = null;
        }
      } catch (e) {
        print('Error fetching user data: $e');
        _user = null;
      }
    } else {
      _user = null;
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
    bool isAdmin = false,
  }) async {
    try {
      print('SignUp: Starting signup process for email: $email');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // The email validation will be handled by Firebase automatically
      // If email already exists, it will throw 'email-already-in-use' error

      print('SignUp: Creating user with Firebase Auth');
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('SignUp: User created successfully with UID: ${result.user?.uid}');

      if (result.user != null) {
        print('SignUp: Creating UserModel and saving to Firestore');
        UserModel newUser = UserModel(
          id: result.user!.uid,
          name: name,
          email: email,
          phone: phone,
          address: address,
          isAdmin: isAdmin,
        );

        // Use batch write for better reliability
        WriteBatch batch = _firestore.batch();
        DocumentReference userRef = _firestore
            .collection('users')
            .doc(result.user!.uid);

        batch.set(userRef, newUser.toJson());
        await batch.commit();
        print('SignUp: User data saved to Firestore successfully');

        _user = newUser;
        _isLoading = false;
        notifyListeners();
        print('SignUp: Signup completed successfully');
        return true;
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth Error during sign up: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'weak-password':
          _errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          _errorMessage = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          _errorMessage = 'The email address is not valid.';
          break;
        case 'operation-not-allowed':
          _errorMessage = 'Email/password accounts are not enabled.';
          break;
        default:
          _errorMessage = 'An error occurred during sign up: ${e.message}';
      }
    } on FirebaseException catch (e) {
      print('Firestore Error during sign up: ${e.code} - ${e.message}');
      _errorMessage = 'Failed to save user data: ${e.message}';
    } catch (e) {
      print('Unexpected error during sign up: $e');
      _errorMessage = 'An unexpected error occurred. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      print('SignIn: Starting signin process for email: $email');
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(
        'SignIn: User signed in successfully with UID: ${result.user?.uid}',
      );

      // The _onAuthStateChanged will handle fetching user data
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth Error during sign in: ${e.code} - ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          _errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          _errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          _errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          _errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          _errorMessage = 'Too many attempts. Please try again later.';
          break;
        case 'invalid-credential':
          _errorMessage = 'Invalid email or password.';
          break;
        default:
          _errorMessage = 'An error occurred during sign in: ${e.message}';
      }
    } catch (e) {
      print('Unexpected error during sign in: $e');
      _errorMessage = 'An unexpected error occurred. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  // Method to check if user is authenticated
  bool get isAuthenticated => _user != null;

  // Method to get current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;
}
