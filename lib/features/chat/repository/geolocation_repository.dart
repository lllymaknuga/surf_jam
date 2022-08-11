import 'package:geolocator/geolocator.dart';

class GeolocationRepository {
  const GeolocationRepository();

  Future<bool> hasPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  Future<Position> getCurrentLocation() async {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}
