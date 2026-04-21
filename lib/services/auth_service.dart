import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> register(String email, String password, String name) async {
    try {
      final res = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user != null) {
        // Check if user document already exists
        final userDoc = await _db.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          // Create user document if doesn't exist
          await _db.collection('users').doc(user.uid).set({
            'name': name,
            'email': email,
            'role': 'user', // Default role
            'isAdmin': false,
            'isBanned': false,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Update existing document if needed
          await _db.collection('users').doc(user.uid).update({
            'name': name,
            'email': email,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // If email already in use, just rethrow - let user know to login instead
      rethrow;
    } catch (e) {
      print('Register error: $e');
      rethrow;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final res = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = res.user;
      
      if (user != null) {
        // Ensure user document exists in Firestore
        final userDoc = await _db.collection('users').doc(user.uid).get();
        
        if (!userDoc.exists) {
          // Create user document if doesn't exist (for users created before this fix)
          await _db.collection('users').doc(user.uid).set({
            'name': user.displayName ?? email.split('@')[0],
            'email': email,
            'role': 'user',
            'isAdmin': false,
            'isBanned': false,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      
      return user;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async => _auth.signOut();

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
