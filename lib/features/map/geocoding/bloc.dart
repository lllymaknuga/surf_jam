import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

part 'event.dart';

part 'state.dart';

class GeocodingBloc extends Bloc<GeocodingEvent, GeocodingState> {
  GeocodingBloc(LatLng latLng) : super(GeocodingState(position: latLng)) {
    on<GeocodingEvent>(_onGeocoding);
  }

  void _onGeocoding(GeocodingEvent event, Emitter emit) {
    emit(GeocodingState(position: event.position));
  }

}
