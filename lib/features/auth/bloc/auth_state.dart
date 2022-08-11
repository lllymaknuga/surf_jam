part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class InitialAuthState extends AuthState {
  const InitialAuthState();
}

class UnknownAuthState extends AuthState {
  const UnknownAuthState();
}

class LoadingAuthState extends AuthState {
  const LoadingAuthState();
}

class AuthenticatedAuthState extends AuthState {
  final TokenDto token;

  const AuthenticatedAuthState({required this.token});
}

class ErrorAuthState extends AuthState {
  final String errorText;

  const ErrorAuthState({required this.errorText});
}
