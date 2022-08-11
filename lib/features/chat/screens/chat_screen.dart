import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_geolocation_geolocation_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_location_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';

import '../../map/map_screen.dart';
import '../repository/geolocation_repository.dart';

typedef MyVoidCallback<T, P> = Future<void> Function(T value, P position);

/// Main screen of chat app, containing messages.
class ChatScreen extends StatefulWidget {
  /// Repository for chat functionality.
  final IChatRepository chatRepository;

  /// Constructor for [ChatScreen].
  const ChatScreen({
    required this.chatRepository,
    Key? key,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _nameEditingController = TextEditingController();

  Iterable<ChatMessageDto> _currentMessages = [];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: _ChatAppBar(
          controller: _nameEditingController,
          onUpdatePressed: _onUpdatePressed,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ChatBody(
              messages: _currentMessages,
            ),
          ),
          _ChatTextField(
            onSendPressed: _onSendPressed,
            onSendLongPressed: _onSendLongPressed,
          ),
        ],
      ),
    );
  }

  Future<void> _onUpdatePressed() async {
    final messages = await widget.chatRepository.getMessages();
    setState(() {
      _currentMessages = messages;
    });
  }

  Future<void> _onSendPressed(String messageText) async {
    final messages = await widget.chatRepository.sendMessage(messageText);
    setState(() {
      _currentMessages = messages;
    });
  }

  Future<void> _onSendLongPressed(String messageText, Position position) async {
    print(21312);
    final messages = await widget.chatRepository.sendGeolocationMessage(
        message: messageText,
        location: ChatGeolocationDto(
          longitude: position.longitude,
          latitude: position.latitude,
        ));
    setState(() {
      _currentMessages = messages;
    });
  }
}

class _ChatBody extends StatelessWidget {
  final Iterable<ChatMessageDto> messages;

  const _ChatBody({
    required this.messages,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (_, index) {
        print(
            messages.elementAt(index).runtimeType == ChatMessageGeolocationDto);
        if (messages.elementAt(index).runtimeType ==
            ChatMessageGeolocationDto) {
          return _ChatGeolocationMessage(
            chatData: messages.elementAt(index) as ChatMessageGeolocationDto,
          );
        }
        return _ChatMessage(
          chatData: messages.elementAt(index),
        );
      },
    );
  }
}

class _ChatTextField extends StatefulWidget {
  final ValueChanged<String> onSendPressed;

  final MyVoidCallback<String, Position> onSendLongPressed;

  const _ChatTextField({
    required this.onSendPressed,
    Key? key,
    required this.onSendLongPressed,
  }) : super(key: key);

  @override
  State<_ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<_ChatTextField> {
  final _textEditingController = TextEditingController();
  final GeolocationRepository _geolocationRepository =
      const GeolocationRepository();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      elevation: 12,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: mediaQuery.padding.bottom + 8,
          left: 16,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Сообщение',
                ),
              ),
            ),
            IconButton(
              onPressed: () =>
                  widget.onSendPressed(_textEditingController.text),
              icon: const Icon(Icons.send),
              color: colorScheme.onSurface,
            ),
            IconButton(
              onPressed: () async {
                bool hasPermission =
                    await _geolocationRepository.hasPermission();
                if (hasPermission) {
                  final Position position =
                      await _geolocationRepository.getCurrentLocation();
                  widget.onSendLongPressed(
                      _textEditingController.text, position);
                }
              },
              icon: const Icon(Icons.map),
            )
          ],
        ),
      ),
    );
  }
}

class _ChatAppBar extends StatelessWidget {
  final VoidCallback onUpdatePressed;
  final TextEditingController controller;

  const _ChatAppBar({
    required this.onUpdatePressed,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            onPressed: onUpdatePressed,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage extends StatelessWidget {
  final ChatMessageDto chatData;

  const _ChatMessage({
    required this.chatData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: chatData.chatUserDto is ChatUserLocalDto
          ? colorScheme.primary.withOpacity(.1)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChatAvatar(userData: chatData.chatUserDto),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    chatData.chatUserDto.name ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(chatData.message ?? ''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatGeolocationMessage extends StatelessWidget {
  final ChatMessageGeolocationDto chatData;

  const _ChatGeolocationMessage({
    required this.chatData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: chatData.chatUserDto is ChatUserLocalDto
          ? colorScheme.primary.withOpacity(.1)
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  return MapScreen(center: chatData.location,);
                },
              ),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ChatAvatar(userData: chatData.chatUserDto),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      chatData.chatUserDto.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(chatData.message ?? ''),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  static const double _size = 42;

  final ChatUserDto userData;

  const _ChatAvatar({
    required this.userData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: _size,
      height: _size,
      child: Material(
        color: colorScheme.primary,
        shape: const CircleBorder(),
        child: Center(
          child: Text(
            userData.name != null
                ? '${userData.name!.split(' ').first[0]}${userData.name!.split(' ').last[0]}'
                : '',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
