import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Mapweb extends StatefulWidget {
  final user;
  final Widget? sidebar;

  const Mapweb({super.key, required this.user, this.sidebar});

  @override
  State<Mapweb> createState() => _MapwebState();
}

class _MapwebState extends State<Mapweb> {
  final LatLng _center = LatLng(38.73, -9.14);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LayoutGrid(
            areas: '''
                  s h     
                  s l   
                  s l
                ''',
            // Concise track sizing extension methods 🔥
            columnSizes: [0.7.fr, 3.8.fr],
            rowSizes: [
              0.2.fr,
              1.0.fr,
              3.0.fr,
            ],
            // Column and row gaps! 🔥
            columnGap: 0,
            rowGap: 0,
            children: [
              gridArea('s').containing(Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 10)),
                  child: widget.sidebar)),
              gridArea('l').containing(Container(
                child: FlutterMap(
                    options: MapOptions(
                      initialCenter: widget.user['lat'] != 0.1 &&
                              widget.user['long'] != 0.1
                          ? LatLng(widget.user['lat'], widget.user['long'])
                          : _center,
                      initialZoom: 20.0,
                    ),
                    children: [
                      TileLayer(
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c']),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 60,
                            height: 60,
                            point:
                                LatLng(widget.user['lat'], widget.user['long']),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(1),
                              child: Column(
                                children: [


                                Image.asset("images/baby-boy.png", width: 50)
                           ]) ),
                          ),
                        ],
                      ),
                    ]),
              )),
              gridArea('h').containing(
                Container(
                    color: Colors.black,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Text("Localização",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white)),
                          )
                        ])),
              )
            ]));
  }
}
