
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Maps extends StatefulWidget {
  final user;

  const Maps(
      {super.key, required this.user});

  @override
  State<Maps> createState() => _MapsState();

}

class _MapsState extends State<Maps> {

  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;

  late GoogleMapController mapController;

  final LatLng _center = LatLng(38.73,-9.14);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    addCustomIcon();
    super.initState();

  }

  Future<void> navigateTo(double lat, double long) async{
    var uri = Uri.parse("google.navigation:q=$lat,$long&mode=d");
    if(await canLaunchUrl(uri)){
      await launchUrl(uri);
    }
    else {
      throw 'Could not launch${uri}';
    }
  }

  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(), "images/baby-boy.png")
        .then(
          (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Localização'),
        ),
        body: Stack(
          children: [
            GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: widget.user['lat'] != 0.1 && widget.user['long'] != 0.1 ?
              LatLng(widget.user['lat'],widget.user['long']): _center,
            zoom: 11.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId("Aqui"),
              position: LatLng(widget.user['lat'],widget.user['long']),
              icon: markerIcon,
            ),
          },
        ),
        ]
        ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: Text("Google Maps"),
        onPressed: () => navigateTo(widget.user['lat'],widget.user['long']),
        icon: Icon(Icons.map_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
  }
}
