import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Handles client-side social authentication via Firebase Auth.
///
/// Each provider follows the same contract:
/// 1. Trigger the native sign-in flow on the device.
/// 2. Obtain an OAuth credential for that provider.
/// 3. Sign in to Firebase Auth with that credential.
/// 4. Return the Firebase ID Token for the backend to verify.
class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // ─────────────── Google ───────────────

  /// Triggers the full Google Sign-In flow.
  ///
  /// Returns a Firebase ID Token on success, or `null` if the user cancels.
  Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('[SocialAuth] Google sign-in cancelled by user.');
        return null;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        debugPrint('[SocialAuth] Failed to retrieve Firebase ID Token.');
        return null;
      }

      debugPrint('[SocialAuth] Google sign-in successful.');
      return idToken;
    } on Exception catch (e) {
      debugPrint('[SocialAuth] Google sign-in error: $e');
      rethrow;
    }
  }

  // ─────────────── Apple ───────────────

  /// Triggers the native Apple Sign-In flow (requires "Sign in with Apple"
  /// capability in the Xcode project).
  ///
  /// Returns a Firebase ID Token on success, or `null` if the user cancels.
  Future<String?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oauthCredential);
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        debugPrint('[SocialAuth] Failed to retrieve Firebase ID Token.');
        return null;
      }

      debugPrint('[SocialAuth] Apple sign-in successful.');
      return idToken;
    } on PlatformException catch (e) {
      // User cancelled or the flow was interrupted.
      if (e.code == 'canceled' || e.code == 'authorization_failed') {
        debugPrint('[SocialAuth] Apple sign-in cancelled.');
        return null;
      }
      debugPrint('[SocialAuth] Apple sign-in platform error: $e');
      rethrow;
    } on Exception catch (e) {
      debugPrint('[SocialAuth] Apple sign-in error: $e');
      rethrow;
    }
  }

  // ─────────────── Facebook ───────────────

  /// Triggers the Facebook Login flow.
  ///
  /// Returns a Firebase ID Token on success, or `null` if the user cancels.
  Future<String?> signInWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        debugPrint('[SocialAuth] Facebook sign-in cancelled or failed.');
        return null;
      }

      final accessToken = result.accessToken;
      if (accessToken == null) {
        debugPrint('[SocialAuth] Facebook access token is null.');
        return null;
      }

      final credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        debugPrint('[SocialAuth] Failed to retrieve Firebase ID Token.');
        return null;
      }

      debugPrint('[SocialAuth] Facebook sign-in successful.');
      return idToken;
    } on Exception catch (e) {
      debugPrint('[SocialAuth] Facebook sign-in error: $e');
      rethrow;
    }
  }

  // ─────────────── Sign Out ───────────────

  /// Signs out from Firebase Auth and all social providers.
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
      FacebookAuth.instance.logOut(),
    ]);
  }
}
