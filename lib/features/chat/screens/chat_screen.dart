// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:surf_practice_chat_flutter/features/auth/bloc/auth_bloc.dart';
import 'package:surf_practice_chat_flutter/features/chat/blocs/message/message_bloc.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_message_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/models/chat_user_local_dto.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';
import 'package:surf_practice_chat_flutter/features/images/images_srcreen.dart';
import 'package:surf_practice_chat_flutter/features/map/map_screen.dart';

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
    return BlocProvider(
      create: (_) => MessageBloc(
        widget.chatRepository,
      ),
      child: BlocConsumer<MessageBloc, MessageState>(
        listener: (context, state) {
          if (state.status == Status.sended) {
            _onUpdatePressed();
          }
        },
        builder: (context, state) {
          print(state.position);
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: _ChatAppBar(
                onUpdatePressed: _onUpdatePressed,
                controller: _nameEditingController,
              ),
            ),
            body: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -1,
                  child: Image.asset(
                    'assets/images/background_chat.jpeg',
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: _ChatBody(
                        messages: _currentMessages,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _ChatTextField(
                        state: state,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onUpdatePressed() async {
    final messages = await widget.chatRepository.getMessages();
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
        if (messages.elementAt(index).chatUserDto is ChatUserLocalDto) {
          return _SendMessage(
            chatData: messages.elementAt(index),
          );
        }
        return GestureDetector(
          child: _ReceivedMessage(
            chatData: messages.elementAt(index),
          ),
        );
      },
    );
  }
}

class _ChatTextField extends StatefulWidget {
  final MessageState state;

  const _ChatTextField({
    Key? key,
    required this.state,
  }) : super(key: key);

  @override
  State<_ChatTextField> createState() => _ChatTextFieldState();
}

class _ChatTextFieldState extends State<_ChatTextField> {
  final _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: mediaQuery.padding.bottom + 8,
        left: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.state.images != null)
            const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: Text(
                'Вы приложили фотогофии(-ю)',
                style: TextStyle(color: Colors.white),
              ),
            ),
          if (widget.state.position != null)
            const Text(
              'Вы приложили геолокацию',
              style: TextStyle(color: Colors.white),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textEditingController,
                  cursorColor: const Color.fromRGBO(135, 116, 225, 1),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromRGBO(33, 33, 33, 1),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    hintText: 'Сообщение',
                    suffixIcon: GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        builder: (_) => _BottomSheet(
                          photoTap: () async {
                            var data = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const ImageScreen();
                                },
                              ),
                            );
                            if (data['select']) {
                              context.read<MessageBloc>().add(
                                  ChangeImagesMessageEvent(
                                      images: data['images']));
                            }
                            Navigator.of(context).pop();
                          },
                          geoTap: () async {
                            var data = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return const MapScreen();
                                },
                              ),
                            );
                            if (data['select']) {
                              context.read<MessageBloc>().add(
                                  ChangePositionMessageEvent(
                                      position: data['position']));
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                      child: const Icon(
                        Icons.attach_file,
                        color: Colors.blue,
                      ),
                    ),
                    hintStyle: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  onPressed: () {
                    context.read<MessageBloc>().add(SendMessageEvent(
                          message: _textEditingController.text,
                        ));
                    _textEditingController.text = '';
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    primary: const Color.fromRGBO(135, 116, 225, 1),
                    // <-- Button color
                    onPrimary: Colors.white, // <-- Splash color
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomSheet extends StatelessWidget {
  final VoidCallback photoTap;
  final VoidCallback geoTap;

  const _BottomSheet({Key? key, required this.geoTap, required this.photoTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(33, 33, 33, 1),
      margin: const EdgeInsets.all(18.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _IconBottomSheet(
                  icon: Icons.insert_photo,
                  color: Colors.purple,
                  text: "Фото",
                  onTap: photoTap,
                ),
                const SizedBox(
                  width: 50,
                ),
                _IconBottomSheet(
                  icon: Icons.location_pin,
                  color: Colors.teal,
                  text: "Геоданные",
                  onTap: geoTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBottomSheet extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback onTap;

  const _IconBottomSheet({
    Key? key,
    required this.icon,
    required this.color,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
            primary: color, // <-- Button color
            onPrimary: Colors.white, // <-- Splash color
          ),
          child: Icon(
            icon,
            // semanticLabel: "Help",
            size: 29,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 12, color: Colors.white
              // fontWeight: FontWeight.w100,
              ),
        )
      ],
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
      backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.read<AuthBloc>().add(const LogOutAuthEvent());
        },
      ),
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

class _ReceivedMessage extends StatelessWidget {
  final ChatMessageDto chatData;

  const _ReceivedMessage({Key? key, required this.chatData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: _ChatAvatar(userData: chatData.chatUserDto),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: Color.fromRGBO(33, 33, 33, 1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    chatData.chatUserDto.name ?? '',
                    style: TextStyle(color: Colors.purple[400]),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7),
                  child: Text(
                    chatData.message ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Comfortaa',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    chatData.location != null
                        ? TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return _SeePosition(
                                      center: LatLng(
                                        chatData.location!.latitude,
                                        chatData.location!.longitude,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              'Посмотреть геоданные',
                              style: TextStyle(fontSize: 11),
                            ),
                          )
                        : const SizedBox(),
                    chatData.images != null
                        ? TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return _SeeImages(
                                      images: chatData.images as List<String>,
                                    );
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              'Посмотреть фото',
                              style: TextStyle(fontSize: 11),
                            ),
                          )
                        : const SizedBox(),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _SendMessage extends StatelessWidget {
  final ChatMessageDto chatData;

  const _SendMessage({Key? key, required this.chatData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: Color.fromRGBO(135, 116, 225, 1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7),
              child: Text(
                chatData.message ?? '',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  static const double _size = 40;

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
                ? '${userData.name!.trim().split(' ').first[0]}${userData.name!.trim().split(' ').last[0]}'
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

class _SeeImages extends StatelessWidget {
  final List<String> images;

  const _SeeImages({Key? key, required this.images}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
      ),
      body: Stack(
        children: [
          Positioned(
            right: -1,
            child: ColorFiltered(
              colorFilter:
                  const ColorFilter.mode(Colors.purple, BlendMode.colorDodge),
              child: Image.asset(
                'assets/images/background.jpg',
              ),
            ),
          ),
          ColoredBox(
            color: const Color.fromRGBO(33, 33, 33, 0.5),
            child: ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Column(children: [
                  Image.network(
                    images[index],
                    height: 200,
                    width: 200,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SeePosition extends StatelessWidget {
  final LatLng center;

  const _SeePosition({
    Key? key,
    required this.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final normalLat = (-90 <= center.latitude && center.latitude >= 90);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
      ),
      backgroundColor: colorScheme.background,
      body:  normalLat
          ? _Map(
              center: center,
            )
          : Stack(children: [
              Positioned(
                right: -1,
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                      Colors.purple, BlendMode.colorDodge),
                  child: Image.asset(
                    'assets/images/background.jpg',
                  ),
                ),
              ),
              const ColoredBox(
                  color: Color.fromRGBO(33, 33, 33, 0.5),
                  child: _ErrorScreen()),
            ]),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Center(
            child: Text(
          'Введены некорректные геоданные',
              style: TextStyle(color: Colors.white),
        ))
      ],
    );
  }
}

class _Map extends StatelessWidget {
  final LatLng center;

  const _Map({
    Key? key,
    required this.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: center,
        zoom: 11.0,
        minZoom: 10.0,
        maxZoom: 18.0,
        interactiveFlags: InteractiveFlag.pinchZoom |
            InteractiveFlag.drag |
            InteractiveFlag.flingAnimation,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'dev.flutter_map.example',
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              width: 32,
              height: 32,
              point: center,
              builder: (ctx) => Image.asset('assets/images/marker.png'),
            ),
          ],
        )
      ],
    );
  }
}
