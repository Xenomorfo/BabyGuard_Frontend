
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myapp/pages/config_chair.dart';
import 'package:myapp/pages/login.dart';
import 'package:myapp/pages/edit_profile.dart';
import 'dart:convert';
import 'package:myapp/pages/new_password.dart';
import 'history.dart';
import 'map.dart';

class Dashboard extends StatefulWidget {
  final user;

  const Dashboard(
      {super.key, required this.user});
  @override
  State<Dashboard> createState() => _DashboardState();

}

class _DashboardState extends State<Dashboard> {
  Future getData() async {
    String token = widget.user["token"].toString();
    var url = 'http://192.168.1.5:3000/dashboard';
    var response = await http.get(
        Uri.parse(url),
        headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
    });
    widget.user['lat'] = jsonDecode(response.body)['events']['lat'];
    widget.user['long'] = jsonDecode(response.body)['events']['long'];
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

  }


  Widget build(BuildContext context) {

    Widget menuDrawer() {
      return Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Colors.lightBlue),
              currentAccountPicture: GestureDetector(
                  child:  CircleAvatar(
                    backgroundImage: AssetImage("images/bebe_auto_clip.jpg"),
                  )),
              accountName: Text(widget.user["name"]),
              accountEmail: Text(''),
            ),
            ListTile(
              onTap: () {
                //debugPrint("dashboard");
                Navigator.of(context).pop();
              },
              leading: Icon(Icons.dashboard),
              title: Text(
                'Painel',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),

            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Maps(
                        user: widget.user),
                  ),
                );
                //debugPrint("dashboard");
              },
              leading: Icon(Icons.map),
              title: Text(
                'Localização',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),

            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => History(
                        user: widget.user),
                  ),
                );
              },
              leading: Icon(Icons.hourglass_empty),
              title: Text(
                'Histórico',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),


            ListTile(
              onTap: () {
                //debugPrint(widget.user["serial"]);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Editprofile(
                        user: widget.user),
                  ),
                );
              },
              leading: Icon(Icons.person),
              title: Text(
                'Editar Perfil',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
            ListTile(
              onTap: () {
                //debugPrint("dashboard");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Configchair(
                        user: widget.user),
                  ),
                );
              },
              leading: Icon(Icons.child_care),
              title: Text(
                'Config. Cadeira',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovaPassword(
                        user: widget.user),
                  ),
                );
              },
              leading: Icon(Icons.password),
              title: Text(
                'Alterar Senha',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),

            ListTile(
              onTap: () {
                //debugPrint("logout");
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Sair da Aplicação'),
                        content: Text('Tem a certeza que quer sair?'),
                        actions: <Widget>[
                          TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyHomePage(),
                                ),
                              ),
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue),
                              foregroundColor: MaterialStateProperty.all(Colors.white)),
                              child: Text('Sim')),
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue),
                                  foregroundColor: MaterialStateProperty.all(Colors.white)),
                              child: Text('Não')),
                        ],
                      );
                    }
                );
              },
              leading: Icon(Icons.logout),
              title: Text(
                'Sair',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            )
          ],
        ),
      );

    }
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
      child: Scaffold(
      appBar: AppBar(
        title: Text('Painel'),
      ),
      body: FutureBuilder(
        future: getData(),
          builder: (context, snapshot) {
          if (snapshot.hasData) {
            //return Text(snapshot.data);
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
              child:GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(3.0),
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  makeDashboardItem(readTimestamp(snapshot.data['events']['timestamp']).toString(),
                      Icons.timelapse,
                      'Ultimo Evento', Color.fromRGBO(160, 160, 160, 1.0)),
                  if (snapshot.data['events']['seat']==1)
                    makeDashboardItem('Presente',
                        Icons.present_to_all, 'Criança', Color.fromRGBO(0, 150, 0, 1.0))
                  else makeDashboardItem('Ausente',
                      Icons.present_to_all, 'Criança', Color.fromRGBO(222, 215, 25, 1.0)), // Presença de criança
                  if (snapshot.data['events']['belt']==1)
                    makeDashboardItem('Fechado',
                        Icons.lock,'Cinto',Color.fromRGBO(0, 150, 0, 1.0))
                  else makeDashboardItem('Aberto',
                      Icons.lock,'Cinto',Color.fromRGBO(222, 215, 25, 1.0)), // Cinto de segurança
                  if (snapshot.data['events']['car']==1)
                    makeDashboardItem('Fechada',
                        Icons.car_rental, 'Viatura',Color.fromRGBO(0, 150, 0, 1.0))
                  else makeDashboardItem('Aberta',
                      Icons.car_rental, 'Viatura',Color.fromRGBO(250, 0, 0, 1.0)),// Estado portas da viatura
                    makeDashboardItem(snapshot.data['events']['lat'].toString()+"\n"+snapshot.data['events']['long'].toString(),
                       Icons.gps_fixed,
                       'Localização', Color.fromRGBO(0, 150, 0, 1.0)),
                  if (snapshot.data['events']['blue']==1)
                    makeDashboardItem('Emparelhado',
                        Icons.bluetooth_connected,'Bluetooth',Color.fromRGBO(0, 150, 0, 1.0))
                  else makeDashboardItem('Desemparelhado',
                      Icons.bluetooth,'Bluetooth',Color.fromRGBO(222, 215, 25, 1.0)), // Cinto de segurança
                  if (snapshot.data['events']['temperature']>30)
                    makeDashboardItem(snapshot.data['events']['temperature'].toString() + " ºC",
                      Icons.thermostat, 'Temperatura', Color.fromRGBO(250, 0, 0, 1.0))
                  else makeDashboardItem(snapshot.data['events']['temperature'].toString() + " ºC",
                      Icons.thermostat, 'Temperatura', Color.fromRGBO(0, 150, 0, 1.0)), // Temperatura
                  if (snapshot.data['events']['humidity']>70)
                    makeDashboardItem(snapshot.data['events']['humidity'].toString() + " %",
                      Icons.water_drop, 'Humidade',Color.fromRGBO(250, 0, 0, 1.0))
                  else makeDashboardItem(snapshot.data['events']['humidity'].toString() + " %",
                      Icons.water_drop, 'Humidade',Color.fromRGBO(0, 150, 0, 1.0)), // Humidade
                ],
              ),
            );
          } else {
            return Text('Loading...');
          }
        },
      ),
      drawer: menuDrawer(),
    )
    );

  }

  Card makeDashboardItem(String title, IconData icon, String subtitle, Color color) {
    return Card(
        elevation: 1.0,
        margin: new EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(color: color,
              borderRadius: BorderRadius.all(Radius.circular(20))
          ),
          child: new InkWell(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                SizedBox(height: 20.0),
                Center(
                    child: Icon(
                  icon,
                  size: 30.0,
                  color: Colors.black,
                )),
                SizedBox(height: 10.0),
                new Center(
                  child: new Text(title,
                      style: new TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 5.0),
                new Center(
                  child: new Text(subtitle,
                      style:
                          new TextStyle(fontSize: 20.0, color: Colors.black)),
                )
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

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
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
