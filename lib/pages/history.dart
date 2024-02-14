
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
    var url = 'http://192.168.1.5:3000/history';
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
                  for (int i=0; i < snapshot.data['events'].length;i++)
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
          decoration: BoxDecoration(color: Colors.grey,
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
                  child: new Text('Viatura: '+snapshot['car'].toString() +
                      ' Cinto: '+snapshot['belt'].toString() + '\n' +
                      'Bluetooth: '+snapshot['blue'].toString() +
                      ' Criança: '+snapshot['seat'].toString() + '\n' +
                      'Temperatura: '+snapshot['temperature'].toString() +
                      ' Humidade: '+snapshot['humidity'].toString() + '\n' +
                      'Localização: '+snapshot['lat'].toString() +
                      ' '+snapshot['long'].toString(),
                      style:
                      new TextStyle(fontSize: 15.0, color: Colors.black))
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
