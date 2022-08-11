import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/token_dto.dart';
import '../repository/auth_repository.dart';
import '../token_storage.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final MyTokenStorage _tokenStorage = MyTokenStorage();
  final AuthRepository _repository;

  AuthBloc(AuthRepository repository)
      : _repository = repository,
        super(const InitialAuthState()) {
    on<LoginAuthEvent>(_onLogin);
    on<CheckAuthEvent>(_onCheck);
    on<LogOutAuthEvent>(_onLogOut);
  }

  Future<void> _onLogin(LoginAuthEvent event, Emitter emit) async {
    try {
      emit(const LoadingAuthState());
      TokenDto token = await _repository.signIn(
          login: event.login, password: event.password);
      emit(AuthenticatedAuthState(token: token));
    } catch (e) {
      // TODO: error handle(For example Sentry)
      emit(ErrorAuthState(errorText: e.toString()));
    }
  }

  Future<void> _onCheck(CheckAuthEvent event, Emitter emit) async {
    emit(const LoadingAuthState());
    String? token = await _tokenStorage.readToken();
    if (token.runtimeType is String) {
      TokenDto tokenDto = TokenDto(token: token as String);
      emit(AuthenticatedAuthState(token: tokenDto));
    } else {
      emit(const UnknownAuthState());
    }
  }

  Future<void> _onLogOut(LogOutAuthEvent event, Emitter emit) async {
    emit(const LoadingAuthState());
    await _tokenStorage.deleteToken();
    emit(const UnknownAuthState());
  }
}
