import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:surf_practice_chat_flutter/features/chat/repository/geolocation_repository.dart';

part 'event.dart';

part 'state.dart';

extension PositionPasrsing on Position {
  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}

class MyGeolocationBloc
    extends Bloc<GetMyGeolocationEvent, MyGeolocationState> {
  final GeolocationRepository _repository;

  MyGeolocationBloc({required GeolocationRepository repository})
      : _repository = repository,
        // TODO: Substitute it with the city center.
        super(MyGeolocationState(position: LatLng(55.7522200, 37.6155600))) {
    on<GetMyGeolocationEvent>(_onGet);
  }

  Future _onGet(GetMyGeolocationEvent event, Emitter emit) async {
    final bool permission = await _repository.hasPermission();
    if (permission) {
      final Position position = await _repository.getCurrentLocation();
      emit(
        MyGeolocationState(position: position.toLatLng()),
      );
    }
  }
}
