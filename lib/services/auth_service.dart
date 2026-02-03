import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await userCredential.user!.updateDisplayName(displayName);
        }

        // Create user document in Firestore
        await _createUserDocument(
          userCredential.user!.uid,
          email,
          displayName,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An error occurred during sign up: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An error occurred during sign in: $e');
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // User cancelled the flow
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        final existing = await getUserData(user.uid);
        if (existing == null) {
          await _createUserDocument(
            user.uid,
            user.email ?? '',
            user.displayName,
          );
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An error occurred during Google sign in: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('An error occurred during sign out: $e');
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An error occurred while sending password reset email: $e');
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    String userId,
    String email,
    String? displayName,
  ) async {
    try {
      print('Creating user document for $userId');
      final userModel = UserModel(
        id: userId,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        preferences: UserPreferences(
          goal: AppConstants.defaultDailyGoal,
          unit: AppConstants.defaultUnit,
          hasCompletedOnboarding: false,
        ),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(userModel.toMap());
      
      print('User document created successfully');
    } catch (e) {
      print('Error creating user document: $e');
      throw Exception('Failed to create user document: $e');
    }
  }

  // Get user document from Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences(
    String userId,
    UserPreferences preferences,
  ) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'preferences': preferences.toMap()});
    } catch (e) {
      throw Exception('Error updating user preferences: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An authentication error occurred: ${e.message}';
    }
  }
}
