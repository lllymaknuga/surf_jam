import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Screen for authorization process.
///
/// Contains [IAuthRepository] to do so.
class AuthScreen extends StatefulWidget {
  /// Repository for auth implementation.
  final IAuthRepository authRepository;

  /// Constructor for [AuthScreen].
  const AuthScreen({
    required this.authRepository,
    Key? key,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // TODO(task): Implement Auth screen.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(AuthRepository(StudyJamClient()))
        ..add(const CheckAuthEvent()),
      child: SafeArea(
        child: Scaffold(
          body: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthenticatedAuthState) {
                _pushToChat(context, state.token);
              } else if (state is ErrorAuthState) {
                final snackBar = SnackBar(
                  content: Text(state.errorText),
                  action: SnackBarAction(
                    label: 'Закрыть',
                    onPressed: () {},
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            },
            builder: (context, state) {
              if (state is LoadingAuthState) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return const _Input();
            },
          ),
        ),
      ),
    );
  }

  void _pushToChat(BuildContext context, TokenDto token) {
    Navigator.push<ChatScreen>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChatScreen(
            chatRepository: ChatRepository(
              StudyJamClient().getAuthorizedClient(token.token),
            ),
          );
        },
      ),
    );
  }
}

class _Input extends StatefulWidget {
  const _Input({Key? key}) : super(key: key);

  @override
  State<_Input> createState() => _InputState();
}

class _InputState extends State<_Input> {
  final TextEditingController _controllerLogin = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  void initState() {
    _controllerLogin.text = 'lllymaknuga';
    _controllerPassword.text = 'SbXAySLHARlr';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextField(
          controller: _controllerLogin,
        ),
        TextField(
          controller: _controllerPassword,
        ),
        ElevatedButton(
          onPressed: () {
            context.read<AuthBloc>().add(LoginAuthEvent(
                login: _controllerLogin.text,
                password: _controllerPassword.text));
          },
          child: const Text('Войти'),
        ),
      ],
    );
  }
}
