import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:surf_practice_chat_flutter/features/auth/repository/auth_repository.dart';
import 'package:surf_practice_chat_flutter/features/auth/screens/auth_screen.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/chat/screens/chat_screen.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

/// App,s main widget.
class MyApp extends StatelessWidget {
  /// Constructor for [MyApp].
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        canvasColor: Colors.transparent,
        fontFamily: 'Comfortaa',
      ),
      home: BlocProvider(
        create: (_) => AuthBloc(AuthRepository(StudyJamClient()))
          ..add(const CheckAuthEvent()),
        child: BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) {
            if (previous is UnknownAuthState && current is ErrorAuthState) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            if (state is AuthenticatedAuthState) {
              return ChatScreen(
                chatRepository: ChatRepository(
                  StudyJamClient().getAuthorizedClient(state.token.token),
                ),
              );
            } else if (state is LoadingAuthState) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              return AuthScreen(
                authRepository: AuthRepository(
                  StudyJamClient(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
