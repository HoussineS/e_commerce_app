import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  //firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //function for signup
  Future<String?> signeUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      // add extra data about user in firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
      });
      return null; // success signup
    } on FirebaseAuthException catch (e) {
      // 🎯 Handle known Firebase auth error codes
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'weak-password':
          return 'The password is too weak. Try something stronger.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        default:
          return 'Signup failed: ${e.message}';
      }
    }
  }

  //function for login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      // get user role
      DocumentSnapshot docSnap = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      return docSnap['role']; // success signin and return thr user role Admin or User
    } on FirebaseAuthException catch (e) {
      // error : return the erore message
      switch (e.code) {
        case 'invalid-email':
          return 'The email address is badly formatted.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password. Please try again.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'invalid-credential':
          return 'Invalid email or password. Please try again.';
        default:
          return 'Login failed. Please try again.';
      }
    }
  }
}
