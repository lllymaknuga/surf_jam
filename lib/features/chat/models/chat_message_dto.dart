import 'package:surf_practice_chat_flutter/features/chat/models/chat_geolocation_geolocation_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_study_jam/surf_study_jam.dart';

/// Data transfer object representing simple chat message.
class ChatMessageDto {
  /// Author of message.
  final ChatUserDto chatUserDto;

  final ChatGeolocationDto? location;

  final List<String>? images;

  /// Chat message string.
  final String? message;

  /// Creation date and time.
  final DateTime createdDateTime;

  /// Constructor for [ChatMessageDto].
  const ChatMessageDto(
      {required this.chatUserDto,
      required this.message,
      required this.createdDateTime,
      this.location,
      this.images});

  /// Named constructor for converting DTO from [StudyJamClient].
  ChatMessageDto.fromSJClient(
      {required SjMessageDto sjMessageDto,
      required SjUserDto sjUserDto,
      required bool isUserLocal,
      this.location,
      this.images})
      : chatUserDto = isUserLocal
            ? ChatUserLocalDto.fromSJClient(sjUserDto)
            : ChatUserDto.fromSJClient(sjUserDto),
        message = sjMessageDto.text,
        createdDateTime = sjMessageDto.created;

  @override
  String toString() =>
      'ChatMessageDto(chatUserDto: $chatUserDto, message: $message, createdDate: $createdDateTime)';
}
