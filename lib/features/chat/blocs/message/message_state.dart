part of 'message_bloc.dart';

enum Status { ending, sended, error, fetch, fetched, initial }

class MessageState {
  final LatLng? position;
  final List<String>? images;

  final Status status;

  MessageState({
    required this.status,
    this.position,
    this.images,
  });

  MessageState copyWith({
    LatLng? position,
    List<String>? images,
    Status? status,
  }) =>
      MessageState(
        position: position,
        images: images,
        status: status ?? this.status,
      );
}
