import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:intl/intl.dart';

class History extends StatefulWidget {
  final user;
  final Widget? sidebar;
  final Future<dynamic>? allData;

  const History({super.key, required this.user, this.allData, this.sidebar});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 640)
      return Scaffold(
        appBar: AppBar(
          title: Text('Histórico'),
        ),
        body: FutureBuilder(
          future: widget.allData,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data['events'].length > 1) {
              return Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
                child: ListView(
                  padding: EdgeInsets.all(3.0),
                  scrollDirection: Axis.vertical,
                  children: [
                    for (int i = snapshot.data['events'].length - 1;
                        i >= 0;
                        i--)
                      _myListContainer(snapshot.data['events'][i]),
                  ],
                ),
              );
            } else {
              return Container(
                  alignment: Alignment.topCenter,
                  child: Column(children: [
                    CircleAvatar(
                      backgroundImage: AssetImage("images/bebe_auto_clip.jpg"),
                      radius: 100,
                    ),
                    SizedBox(height: 8.0),
                    Positioned(
                      child: Text("Sem dados disponiveis"),
                    )
                  ]));
            }
          },
        ),
      );
    else
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
                gridArea('l').containing(FutureBuilder(
                  future: widget.allData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data['events'].length > 1) {
                      return Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 200.0),
                        child: ListView(
                          padding: EdgeInsets.all(3.0),
                          scrollDirection: Axis.vertical,
                          children: [
                            for (int i = snapshot.data['events'].length - 1;
                                i >= 0;
                                i--)
                              _myListContainer(snapshot.data['events'][i]),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                          alignment: Alignment.center,
                          child: Column(
                              children: [
                                SizedBox(height: 50.0),
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage("images/bebe_auto_clip.jpg"),
                              radius: 100,
                            ),
                            SizedBox(height: 50.0),
                            Positioned(
                              child: Text("Sem dados disponiveis"),
                            )
                          ]));
                    }
                  },
                )
                ),
                gridArea('h').containing(
                  Container(
                      color: Colors.black,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text("Histórico",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)),
                            )
                          ])),
                )
              ]));
  }

  Widget _myListContainer(Map<String, dynamic> snapshot) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
            height: MediaQuery.of(context).size.width > 640 ? 175.0 : 150.0,
            child: Material(
                color: Colors.white38,
                elevation: 14.0,
                shadowColor: Color(0x802196F3),
                child: Container(
                  child: Row(children: <Widget>[
                    Container(
                      height: 80.0,
                      width: 10.0,
                      color: snapshot['temperature'] > 40 &&
                              snapshot['seat'] == 1 &&
                              snapshot['belt'] == 1 &&
                              snapshot['car'] == 1
                          ? Colors.red
                          : snapshot['blue'] == 0 ||
                                  (snapshot['lat']) == 0.1 &&
                                      snapshot['long'] == 0.1
                              ? Colors.yellow
                              : Colors.green,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            new Center(
                              child: new Text(
                                  readTimestamp(snapshot['timestamp'])
                                      .toString(),
                                  style: new TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width >
                                                  640
                                              ? 32.0
                                              : 15.0,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(height: 1.0),
                            new Center(
                                child: new Text(
                                    'Viatura: ${snapshot['car'] == 1 ? 'Fechada' : 'Aberta'}' +
                                        ' Cinto: ${snapshot['belt'] == 1 ? 'Fechado' : 'Aberto'}' +
                                        '\n' +
                                        'Bluetooth: ${snapshot['blue'] == 1 ? 'Emparelhado' : 'Desemparelhado'}' +
                                        ' Criança: ${snapshot['seat'] == 1 ? 'Presente' : 'Ausente'}' +
                                        '\n' +
                                        'Temperatura: ' +
                                        snapshot['temperature'].toString() +
                                        'º' +
                                        ' Humidade: ' +
                                        snapshot['humidity'].toString() +
                                        '%\n' +
                                        'Latitude: ' +
                                        snapshot['lat'].toString() +
                                        '\n'
                                            'Longitude: ' +
                                        snapshot['long'].toString(),
                                    style: new TextStyle(
                                        fontSize: 14.0, color: Colors.black))),
                          ],
                        ),
                      ),
                    )
                  ]),
                ))));
  }

  Card makeHistoryItem(Map<String, dynamic> snapshot) {
    return Card(
        elevation: 1.0,
        margin: new EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: snapshot['temperature'] > 40 &&
                    snapshot['seat'] == 1 &&
                    snapshot['belt'] == 1 &&
                    snapshot['car'] == 1
                ? Colors.red
                : snapshot['blue'] == 0 ||
                        (snapshot['lat']) == 0.1 && snapshot['long'] == 0.1
                    ? Colors.yellow
                    : Colors.green,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: new InkWell(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                SizedBox(height: 0),
                new Center(
                  child: new Text(
                      readTimestamp(snapshot['timestamp']).toString(),
                      style: new TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 1.0),
                new Center(
                    child: new Text(
                        'Viatura: ${snapshot['car'] == 1 ? 'Fechada' : 'Aberta'}' +
                            ' Cinto: ${snapshot['belt'] == 1 ? 'Fechado' : 'Aberto'}' +
                            '\n' +
                            'Bluetooth: ${snapshot['blue'] == 1 ? 'Emparelhado' : 'Desemparelhado'}' +
                            ' Criança: ${snapshot['seat'] == 1 ? 'Presente' : 'Ausente'}' +
                            '\n' +
                            'Temperatura: ' +
                            snapshot['temperature'].toString() +
                            'º' +
                            ' Humidade: ' +
                            snapshot['humidity'].toString() +
                            '%\n' +
                            'Latitude: ' +
                            snapshot['lat'].toString() +
                            ' Longitude: ' +
                            snapshot['long'].toString(),
                        style:
                            new TextStyle(fontSize: 14.0, color: Colors.black)))
              ],
            ),
          ),
        ));
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('yyyy-MM-dd HH:mm');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = 'HÁ ' + diff.inDays.toString() + ' DIA(S) ATRÁS';
      } else {
        time = 'HÁ ' + diff.inDays.toString() + ' DIA(S) ATRÁS';
      }
    } else {
      if (diff.inDays == 7) {
        time = 'HÁ' + (diff.inDays / 7).floor().toString() + ' SEMANA(S) ATRÁS';
      } else {
        time =
            'HÁ ' + (diff.inDays / 7).floor().toString() + ' SEMANA(S) ATRÁS';
      }
    }

    return time;
  }
}
