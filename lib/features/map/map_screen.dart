import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:surf_practice_chat_flutter/features/map/geocoding/bloc.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GeocodingBloc(LatLng(55.7522200, 37.6155600)),
      child: const _Screen(),
    );
  }
}

class _Screen extends StatefulWidget {
  const _Screen({Key? key}) : super(key: key);

  @override
  State<_Screen> createState() => _ScreenState();
}

class _ScreenState extends State<_Screen> {
  late final MapController _mapController;
  late final StreamSubscription mapEventSubscription;

  @override
  void initState() {
    _mapController = MapController();
    mapEventSubscription = _mapController.mapEventStream.listen((mapEvent) {
      context
          .read<GeocodingBloc>()
          .add(GeocodingEvent(position: mapEvent.center));
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    mapEventSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GeocodingBloc, GeocodingState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      buildWhen: (_, __) {
        return false;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop({
                'select': false,
              }),
            ),
            title: const Text('Местоположение'),
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: state.position,
                  zoom: 11.0,
                  minZoom: 10.0,
                  maxZoom: 18.0,
                  interactiveFlags: InteractiveFlag.pinchZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.flingAnimation,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate:
                        'https://{s}.maps.2gis.com/tiles?x={x}&y={y}&z={z}',
                    subdomains: ['tile0', 'tile1', 'tile2', 'tile3'],
                  ),
                ],
              ),
              IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 50),
                    child: Image.asset(
                      'assets/images/marker.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, {
                      'select': true,
                      'position': context.read<GeocodingBloc>().state.position,
                    }),
                    child: const Text('Выбрать данное местоположение'),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
