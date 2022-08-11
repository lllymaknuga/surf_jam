import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:surf_practice_chat_flutter/features/auth/models/token_dto.dart';

class MyTokenStorage {
  static const _storage = FlutterSecureStorage();

  Future<void> writeToken(TokenDto tokenDto) async {
    await _storage.write(key: 'accessToken', value: tokenDto.token);
  }

  Future<String?> readToken() async {
    String? accessToken = await _storage.read(key: 'accessToken');
    return accessToken;
  }

  Future deleteToken() async {
    await _storage.delete(key: 'accessToken');
  }
}
