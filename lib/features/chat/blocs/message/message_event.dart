part of 'message_bloc.dart';

abstract class MessageEvent {
  const MessageEvent();
}

class SendMessageEvent extends MessageEvent {
  final String message;

  const SendMessageEvent({required this.message});
}

class FetchMessagesEvent extends MessageEvent {
  const FetchMessagesEvent();
}

class ChangePositionMessageEvent extends MessageEvent {
  LatLng position;

  ChangePositionMessageEvent({required this.position});
}

class ChangeImagesMessageEvent extends MessageEvent {
  List<String> images;

  ChangeImagesMessageEvent({required this.images});
}
