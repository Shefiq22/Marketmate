sealed class AuthState {
  const AuthState();
}

class AuthOnboarding extends AuthState {
  const AuthOnboarding();
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthPendingVerification extends AuthState {
  const AuthPendingVerification();
}

/// The account is authenticated but has no phone number on file yet.
/// Routed to the mandatory Update Profile screen until one is saved.
class AuthNeedsProfileUpdate extends AuthState {
  const AuthNeedsProfileUpdate();
}

class AuthBuyer extends AuthState {
  const AuthBuyer();
}

class AuthSeller extends AuthState {
  const AuthSeller();
}

class AuthRider extends AuthState {
  const AuthRider();
}
