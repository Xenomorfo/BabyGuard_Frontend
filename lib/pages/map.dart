import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Maps extends StatefulWidget {
  final user;

  const Maps(
      {super.key, required this.user});

  @override
  State<Maps> createState() => _MapsState();

}

class _MapsState extends State<Maps> {

  late GoogleMapController mapController;

  final LatLng _center = LatLng(38.73,-9.14);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Localização'),
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId("Aqui"),
              position: LatLng(widget.user['lat'],widget.user['long']),
            ),
          },
        ),
      );
  }
}
