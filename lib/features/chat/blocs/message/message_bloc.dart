import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/chat_repository.dart';

part 'message_event.dart';

part 'message_state.dart';

class MessageBloc extends Bloc<MessageEvent, MessageState> {
  final IChatRepository _repository;

  MessageBloc(IChatRepository repository)
      : _repository = repository,
        super(MessageState(status: Status.initial)) {
    on<ChangePositionMessageEvent>(_changePositionMessage);
    on<ChangeImagesMessageEvent>(_changeImagesMessage);
    on<SendMessageEvent>(_onSendMessage);
    on<FetchMessagesEvent>(_onFetch);
  }

  void _onFetch(FetchMessagesEvent event, Emitter emit) {
    emit(state.copyWith(status: Status.fetch));
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter emit) async {
    await _repository.sendMessage(event.message, state.position, state.images);
    emit(state.copyWith(status: Status.sended, images: null, position: null));
  }

  void _changePositionMessage(ChangePositionMessageEvent event, Emitter emit) {
    emit(state.copyWith(position: event.position, images: state.images));
  }

  void _changeImagesMessage(ChangeImagesMessageEvent event, Emitter emit) {
    emit(state.copyWith(images: event.images,  position: state.position));
  }
}
