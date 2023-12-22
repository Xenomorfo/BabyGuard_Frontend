
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/pages/login.dart';
import 'package:myapp/pages/edit_profile.dart';
import 'dart:convert';

import 'package:myapp/pages/nova_password.dart';

class Dashboard extends StatefulWidget {
  final id;
  final name;
  final email;
  final contact;
  final password;
  final token;

  const Dashboard(
      {super.key, this.token, this.id, this.name, this.email,this.contact, this.password});
  @override
  State<Dashboard> createState() => _DashboardState();

}

class _DashboardState extends State<Dashboard> {
  Future getData() async {
    String token = widget.token.toString();
    var url = 'http://192.168.1.5:3000/dashboard';
    var response = await http.get(
        Uri.parse(url),
        headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
    });

    debugPrint(response.body);
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
              accountName: Text(widget.name),
              accountEmail: Text(''),
            ),
            ListTile(
              onTap: () {
                //debugPrint("dashboard");
              },
              leading: Icon(Icons.dashboard),
              title: Text(
                'Dashboard',
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
                //debugPrint("editar perfil");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Editprofile(
                        id: widget.id, name: widget.name, email: widget.email, contact: widget.contact.toString(), password: widget.password, token: widget.token),
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
                        token: widget.id),
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

    return Scaffold(

      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            //return Text(snapshot.data);

            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
              child: GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(3.0),
                children: <Widget>[
                  makeDashboardItem(snapshot.data['total_nadadores'].toString(),
                      Icons.numbers_sharp, 'Serie'), // Número de série
                  makeDashboardItem(
                      snapshot.data['total_treinadores'].toString(),
                      Icons.bar_chart,
                      'Estado'), // Estado
                  makeDashboardItem(snapshot.data['ph'].toString(),
                      Icons.thermostat, 'Temperatura'), // Temperatura
                  makeDashboardItem(snapshot.data['agua'].toString() + " ºC",
                      Icons.present_to_all, 'Presença'), // Presença de criança
                  makeDashboardItem(
                      snapshot.data['temperatura'].toString() + " ºC",
                      Icons.lock,
                      'Cinto'), // Cinto de segurança
                  makeDashboardItem(snapshot.data['humidade'].toString() + " %",
                      Icons.car_rental, 'Viatura') // Estado portas da viatura
                ],
              ),
            );
          } else {
            return Text('Loading...');
          }
        },
      ),
      drawer: menuDrawer(),
    );

  }

  Card makeDashboardItem(String title, IconData icon, String subtitle) {
    return Card(
        elevation: 1.0,
        margin: new EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(color: Color.fromRGBO(220, 220, 220, 1.0)),
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
                          fontSize: 24.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(height: 10.0),
                new Center(
                  child: new Text(subtitle,
                      style:
                          new TextStyle(fontSize: 24.0, color: Colors.black)),
                )
              ],
            ),
          ),
        ));
  }
}
