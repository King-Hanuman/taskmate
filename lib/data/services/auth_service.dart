import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:taskmate/core/constants/app_constants.dart';

/// Firebase Authentication service wrapper.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Current authenticated user.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Whether user is currently signed in.
  bool get isSignedIn => currentUser != null;

  /// Sign in with email & password.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Register with email & password.
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Update display name
    await credential.user?.updateDisplayName(displayName.trim());
    await credential.user?.reload();
    return credential;
  }

  /// Sign in with Google (google_sign_in 7.x API).
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      // Get idToken from authentication
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } on GoogleSignInException {
      // User cancelled or error occurred
      return null;
    }
  }

  /// Sign out from all providers.
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Get user display name or email fallback.
  String get displayName {
    final user = currentUser;
    if (user == null) return 'User';
    return user.displayName ?? user.email?.split('@').first ?? 'User';
  }

  /// Get user photo URL.
  String? get photoUrl => currentUser?.photoURL;

  /// Real-time stream of user profile data from Firestore.
  Stream<Map<String, dynamic>?> userProfileStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data());
  }

  /// Update user profile photo (URL or base64 string).
  Future<void> updateProfilePhoto({
    String? photoUrl,
    String? photoBase64,
  }) async {
    final user = currentUser;
    if (user == null) return;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      try {
        await user.updatePhotoURL(photoUrl);
      } catch (_) {}
    }

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set({
      'photoUrl': photoUrl,
      'photoBase64': photoBase64,
      'displayName': user.displayName ?? displayName,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Clear user profile photo (reverts to letter avatar).
  Future<void> clearProfilePhoto() async {
    final user = currentUser;
    if (user == null) return;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set({
      'photoUrl': null,
      'photoBase64': null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
