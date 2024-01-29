
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/pages/config_chair.dart';
import 'package:myapp/pages/login.dart';
import 'package:myapp/pages/edit_profile.dart';
import 'dart:convert';

import 'package:myapp/pages/new_password.dart';

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
                //debugPrint("dashboard");
              },
              leading: Icon(Icons.hourglass_empty),
              title: Text(
                'Histórico',
                style: TextStyle(color: Colors.blue.shade900),
              ),
            ),


            ListTile(
              onTap: () {
                //debugPrint("Edit Profile");
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
                'Logout',
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
                  if (snapshot.data['status']==1)
                    makeDashboardItem('Ativo',
                      Icons.bar_chart,
                      'Estado', Color.fromRGBO(0, 150, 0, 1.0))
                  else makeDashboardItem('Inativo',
                      Icons.bar_chart,
                      'Estado', Color.fromRGBO(222, 215, 25, 1.0)),
                  if (snapshot.data['seat']==1)
                    makeDashboardItem('Presente',
                        Icons.present_to_all, 'Criança', Color.fromRGBO(0, 150, 0, 1.0))
                  else makeDashboardItem('Ausente',
                      Icons.present_to_all, 'Criança', Color.fromRGBO(222, 215, 25, 1.0)), // Presença de criança
                  if (snapshot.data['belt']==1)
                    makeDashboardItem('Fechado',
                        Icons.lock,'Cinto',Color.fromRGBO(0, 150, 0, 1.0))
                  else makeDashboardItem('Aberto',
                      Icons.lock,'Cinto',Color.fromRGBO(222, 215, 25, 1.0)), // Cinto de segurança
                  if (snapshot.data['car']==1)
                    makeDashboardItem('Fechada',
                        Icons.car_rental, 'Viatura',Color.fromRGBO(0, 150, 0, 1.0))
                  else makeDashboardItem('Aberta',
                      Icons.car_rental, 'Viatura',Color.fromRGBO(250, 0, 0, 1.0)),// Estado portas da viatura
                    makeDashboardItem(snapshot.data['lat']+"\n"+snapshot.data['long'],
                       Icons.gps_fixed,
                       'Localização', Color.fromRGBO(0, 150, 0, 1.0)),
                  if (snapshot.data['blue']==1)
                    makeDashboardItem('Emparelhado',
                        Icons.bluetooth_connected,'Bluetooth',Color.fromRGBO(0, 150, 0, 1.0))
                  else makeDashboardItem('Desemparelhado',
                      Icons.bluetooth,'Bluetooth',Color.fromRGBO(222, 215, 25, 1.0)), // Cinto de segurança
                  if (snapshot.data['temperature']>30)
                    makeDashboardItem(snapshot.data['temperature'].toString() + " ºC",
                      Icons.thermostat, 'Temperatura', Color.fromRGBO(250, 0, 0, 1.0))
                  else makeDashboardItem(snapshot.data['temperature'].toString() + " ºC",
                      Icons.thermostat, 'Temperatura', Color.fromRGBO(0, 150, 0, 1.0)), // Temperatura
                  if (snapshot.data['humidity']>70)
                    makeDashboardItem(snapshot.data['humidity'].toString() + " %",
                      Icons.water_drop, 'Humidade',Color.fromRGBO(250, 0, 0, 1.0))
                  else makeDashboardItem(snapshot.data['humidity'].toString() + " %",
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
          decoration: BoxDecoration(color: color),
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
                  size: 40.0,
                  color: Colors.black,
                )),
                SizedBox(height: 15.0),
                new Center(
                  child: new Text(title,
                      style: new TextStyle(
                          fontSize: 15.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 15.0),
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
}
