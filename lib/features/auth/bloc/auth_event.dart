part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
}

class LoginAuthEvent extends AuthEvent {
  final String login;
  final String password;

  const LoginAuthEvent({required this.login, required this.password});

  @override
  List<Object?> get props => [login, password];
}

class LogOutAuthEvent extends AuthEvent {
  const LogOutAuthEvent();
}
