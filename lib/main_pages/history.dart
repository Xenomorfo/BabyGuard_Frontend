
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class History extends StatefulWidget {
  final user;

  const History(
      {super.key, required this.user});

  @override
  State<History> createState() => _HistoryState();

}

class _HistoryState extends State<History> {
  Future getData() async {
    String token = widget.user["token"].toString();
    var url = 'http://xenomorfo.ddns.net:3000/history';
    var response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico'),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //return Text(snapshot.data);
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
              child: ListView(
                padding: EdgeInsets.all(3.0),
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  for (int i=snapshot.data['events'].length-1; i >= 0;i--)
                    makeHistoryItem(snapshot.data['events'][i]),
                ],
              ),
            );
          } else {
            return Text('Loading...');
          }
        },
      ),
    );
  }

  Card makeHistoryItem(Map<String,dynamic> snapshot) {
    return Card(
        elevation: 1.0,
        margin: new EdgeInsets.all(8.0),
        child: Container(
          decoration:
          BoxDecoration(color: snapshot['temperature'] > 40
              && snapshot['seat'] == 1
              && snapshot['belt'] == 1
              && snapshot['car'] == 1 ? Colors.red : Colors.green,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)
              ),
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
                  child: new Text(readTimestamp(snapshot['timestamp']).toString(),
                      style: new TextStyle(
                          fontSize: 25.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 1.0),
                new Center(
                  child: new Text('Viatura: ${snapshot['car']==1 ? 'Fechada':'Aberta'}'+
                      ' Cinto: ${snapshot['belt']==1 ? 'Fechado':'Aberto'}' + '\n' +
                      'Bluetooth: ${snapshot['blue']==1 ? 'Emparelhado':'Desemparelhado'}'+
                      ' Criança: ${snapshot['seat']==1 ? 'Presente':'Ausente'}'+ '\n' +
                      'Temperatura: '+snapshot['temperature'].toString() +'º'+
                      ' Humidade: '+snapshot['humidity'].toString() + '%\n' +
                      'Latitude: '+snapshot['lat'].toString() +
                      ' Longitude: '+snapshot['long'].toString(),
                      style:
                      new TextStyle(fontSize: 14.0, color: Colors.black))
                )
              ],
            ),
          ),
        )
    );
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('yyyy-MM-dd HH:mm');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 ||
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
        time = 'HÁ ' + (diff.inDays / 7).floor().toString() + ' SEMANA(S) ATRÁS';
      }
    }

    return time;
  }
}
