import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../chat/models/chat_geolocation_geolocation_dto.dart';

extension Parser on ChatGeolocationDto {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

class MapScreen extends StatelessWidget {
  final ChatGeolocationDto center;

  const MapScreen({Key? key, required this.center}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расположение юзера'),
      ),
      body: FlutterMap(
        options: MapOptions(
          center: center.toLatLng(),
          zoom: 16.0,
          minZoom: 10.0,
          maxZoom: 18.0,
          interactiveFlags: InteractiveFlag.pinchZoom |
              InteractiveFlag.drag |
              InteractiveFlag.flingAnimation,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.maps.2gis.com/tiles?x={x}&y={y}&z={z}',
            subdomains: ['tile0', 'tile1', 'tile2', 'tile3'],
          ),
          MarkerLayerOptions(
            markers: [
              Marker(
                width: 32,
                height: 32,
                point: center.toLatLng(),
                builder: (ctx) =>  Image.asset('assets/images/marker.png'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
