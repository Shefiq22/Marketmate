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

class AuthBuyer extends AuthState {
  const AuthBuyer();
}

class AuthSeller extends AuthState {
  const AuthSeller();
}

class AuthRider extends AuthState {
  const AuthRider();
}
