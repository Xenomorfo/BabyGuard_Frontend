import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myapp/main_pages/config_chair.dart';
import 'package:myapp/main_pages/edit_profile.dart';
import 'package:myapp/main_pages/login.dart';
import 'package:myapp/main_pages/map_web.dart';
import 'dart:convert';
import 'package:myapp/main_pages/new_password.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'history.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashweb extends StatefulWidget {
  final user;

  Dashweb({super.key, required this.user});

  @override
  State<Dashweb> createState() => _DashwebState();
}

class _DashwebState extends State<Dashweb> {
  late var timer;

  Future getLast() async {
    String token = widget.user["token"].toString();
    var url = 'http://xenomorfo.ddns.net:3000/dashboard';
    var response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    widget.user['lat'] = jsonDecode(response.body)['events']['lat'];
    widget.user['long'] = jsonDecode(response.body)['events']['long'];

    return json.decode(response.body);
  }

  Future getAll() async {
    String token = widget.user["token"].toString();
    var url = 'http://xenomorfo.ddns.net:3000/history';
    var response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });
    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 5), (Timer t){
      setState(() {
      });

    });
  }

  Future<dynamic> _showDialog(
      BuildContext context, String status, String title, Color color) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text(title)),
        content: Text(status),
        actions: [
          MaterialButton(
            color: color,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Ok"),
          )
        ],
      ),
    );
  }

  Widget menuGrid() {
    return Scaffold(
      body: ListView(
        children: [
          Container(
              color: Colors.black,
              child: Column(children: [
                SizedBox(height: 20.0),
                Center(
                    child: CircleAvatar(
                        backgroundImage:
                            AssetImage("images/bebe_auto_clip.jpg"),
                        radius: 40)),
                SizedBox(height: 10.0),
                Center(
                    child: Text("BabyGuard",
                        style: TextStyle(fontSize: 20, color: Colors.white))),
                SizedBox(height: 10.0),
                Center(
                    child: Text("Utilizador: " + widget.user["name"],
                        style: TextStyle(fontSize: 10, color: Colors.white))),
              ])),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                MaterialPageRoute(
                  builder: (context) => Dashweb(user: widget.user),
                ),
              );
            },
            leading: Icon(Icons.dashboard),
            title: Text(
              'Painel',
              style: TextStyle(color: Colors.blue.shade900),
            ),
          ),
          ListTile(
            onTap: () {
              if (widget.user['lat'] != 0.1 &&
                  widget.user['long'] != 0.1 &&
                  widget.user['lat'] != null &&
                  widget.user['long'] != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Mapweb(user: widget.user, sidebar: menuGrid()),
                    ));
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Mensagem"),
                    content: Text("Nenhuma localização disponivel!"),
                    actions: [
                      MaterialButton(
                        color: Colors.red,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Ok"),
                      )
                    ],
                  ),
                );
              }

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
                  builder: (context) => History(user: widget.user, allData: getAll(), sidebar: menuGrid()),
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
                  builder: (context) => Editprofile(user: widget.user, sidebar: menuGrid()),
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
                  builder: (context) => Configchair(user: widget.user, sidebar: menuGrid()),
                ),
              );
            },
            leading: Icon(Icons.child_care),
            title: Text(
              'Editar Contatos',
              style: TextStyle(color: Colors.blue.shade900),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NovaPassword(user: widget.user, sidebar:menuGrid()),
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
                            onPressed: () => [
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        maintainState: false,
                                        builder: (context) => MyHomePage(),
                                      ),
                                      (e) => false),
                                ],
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white)),
                            child: Text('Sim')),
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.blue),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white)),
                            child: Text('Não')),
                      ],
                    );
                  });
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

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );


    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text('${value + 0}', style: style),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        '${value + 0}',
        style: style,
      ),
    );
  }

  Widget cards() {
    return Container(
        color: Colors.white,
        child: Scaffold(
          body: FutureBuilder(
            future: getLast(),
            builder: (context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data['events']['timestamp'] != 0.1 &&
                  snapshot.data['serial'].toString().length == 10) {
                return Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
                    child: GridView.count(
                        crossAxisCount: 8,
                        padding: EdgeInsets.all(3.0),
                        scrollDirection: Axis.vertical,
                        children: <Widget>[
                          makeDashboardItem(
                              readTimestamp(
                                      snapshot.data['events']['timestamp'])
                                  .toString(),
                              'Ultimo Evento',
                              Color.fromRGBO(51, 153, 255, 1.0),
                              "images/data-scientist.png"),
                          // Presença de criança
                          if (snapshot.data['events']['seat'] == 1)
                            makeDashboardItem(
                                'Presente',
                                'Criança',
                                Color.fromRGBO(0, 150, 0, 1.0),
                                "images/baby-car-seat.png")
                          else
                            makeDashboardItem(
                                'Ausente',
                                'Criança',
                                Color.fromRGBO(222, 215, 25, 1.0),
                                "images/no-baby-car-seat.png"),
                          // Cinto de segurança
                          if (snapshot.data['events']['belt'] == 1)
                            makeDashboardItem(
                                'Fechado',
                                'Cinto',
                                Color.fromRGBO(0, 150, 0, 1.0),
                                "images/belt.png")
                          else
                            makeDashboardItem(
                                'Aberto',
                                'Cinto',
                                Color.fromRGBO(222, 215, 25, 1.0),
                                "images/belt.png"),
                          // Estado portas da viatura
                          if (snapshot.data['events']['car'] == 1)
                            makeDashboardItem(
                                'Fechada',
                                'Viatura',
                                Color.fromRGBO(0, 150, 0, 1.0),
                                "images/door-closed.png")
                          else
                            makeDashboardItem(
                                'Aberta',
                                'Viatura',
                                Color.fromRGBO(250, 0, 0, 1.0),
                                "images/door-open.png"),
                          // Dados GPS
                          makeDashboardItem(
                              snapshot.data['events']['lat'].toString() +
                                  "\n " +
                                  snapshot.data['events']['long'].toString(),
                              'Localização',
                              Color.fromRGBO(0, 150, 0, 1.0),
                              "images/map.png"),
                          if (snapshot.data['events']['blue'] == 1)
                            makeDashboardItem(
                                'Emparelhado',
                                'Bluetooth',
                                Color.fromRGBO(0, 150, 0, 1.0),
                                "images/bluetooth.png")
                          else
                            makeDashboardItem(
                                'Desemparelhado',
                                'Bluetooth',
                                Color.fromRGBO(222, 215, 25, 1.0),
                                "images/no-bluetooth.png"),
                          // Temperatura e humidade
                          Card(
                              elevation: 2,
                              color: Colors.white38,
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Container(
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white38,
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(20),
                                      )),
                                  child: SfRadialGauge(
                                    axes: <RadialAxis>[
                                      RadialAxis(
                                          minimum: 0.0,
                                          maximum: 50.0,
                                          ranges: <GaugeRange>[
                                            GaugeRange(
                                                startValue: 0.0,
                                                endValue: 20.0,
                                                color: Colors.blue),
                                            GaugeRange(
                                                startValue: 20.0,
                                                endValue: 35.0,
                                                color: Colors.orange),
                                            GaugeRange(
                                                startValue: 35.0,
                                                endValue: 50.0,
                                                color: Colors.red)
                                          ],
                                          pointers: <GaugePointer>[
                                            NeedlePointer(
                                                value: double.parse(snapshot
                                                    .data['events']
                                                        ['temperature']
                                                    .toString()))
                                          ],
                                          annotations: <GaugeAnnotation>[
                                            GaugeAnnotation(
                                                widget: Container(
                                                    child: Text(
                                                        "Temperatura\n        " +
                                                            snapshot
                                                                .data['events'][
                                                                    'temperature']
                                                                .toString() +
                                                            "\u2103",
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                                angle: 90,
                                                positionFactor: 0.5)
                                          ])
                                    ],
                                  ))),
                          Card(
                              elevation: 2,
                              color: Colors.white38,
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
                              child: Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    color: Colors.white38,
                                    borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(20),
                                    )),
                                child: SfRadialGauge(
                                  axes: <RadialAxis>[
                                    RadialAxis(
                                        minimum: 0.0,
                                        maximum: 100.0,
                                        ranges: <GaugeRange>[
                                          GaugeRange(
                                              startValue: 0.0,
                                              endValue: 50.0,
                                              color: Colors.blue),
                                          GaugeRange(
                                              startValue: 50.0,
                                              endValue: 80.0,
                                              color: Colors.orange),
                                          GaugeRange(
                                              startValue: 80.0,
                                              endValue: 100.0,
                                              color: Colors.red)
                                        ],
                                        pointers: <GaugePointer>[
                                          NeedlePointer(
                                              value: double.parse(snapshot
                                                  .data['events']['humidity']
                                                  .toString()))
                                        ],
                                        annotations: <GaugeAnnotation>[
                                          GaugeAnnotation(
                                              widget: Container(
                                                  child: Text(
                                                      "Humidade\n      " +
                                                          snapshot
                                                              .data['events']
                                                                  ['humidity']
                                                              .toString() +
                                                          "%",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              angle: 90,
                                              positionFactor: 0.5)
                                        ])
                                  ],
                                ),
                              )),
                        ]));
              } else {
                return Container(
                    alignment: Alignment.topCenter,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                AssetImage("images/bebe_auto_clip.jpg"),
                            radius: 100,
                          ),
                          Text("Sem dados disponiveis"),
                        ]));
              }
            },
          ),
        ));
  }

  Widget graph() {
    return Container(
        color: Colors.white,
        child: Scaffold(
            body: FutureBuilder(
                future: getAll(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data['events'].length > 0) {
                    double count1 = 0.0;
                    double count2 = 0.0;
                    return Center(
                        child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 18,
                          top: 10,
                          bottom: 4,
                        ),
                        child: LineChart(
                          LineChartData(
                            lineTouchData: const LineTouchData(enabled: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  for(var s in snapshot.data['events'])
                                    FlSpot(count1++,s['temperature'])
                                ],
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.red,
                                dotData: const FlDotData(
                                  show: false,
                                ),

                              ),
                              LineChartBarData(
                                spots: [
                                  for(var s in snapshot.data['events'])
                                    FlSpot(count2++,s['humidity'])
                                ],
                                isCurved: false,
                                barWidth: 2,
                                color: Colors.blue,
                                dotData: const FlDotData(
                                  show: false,
                                ),

                              ),
                            ],
                            minY: 0,
                            borderData: FlBorderData(
                              show: false,
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                axisNameWidget: Text("Ocorrências"),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: bottomTitleWidgets,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                axisNameWidget: Text("Valores"),
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: leftTitleWidgets,
                                  interval: 5,
                                  reservedSize: 36,
                                ),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ));
                  } else {
                    return Container(
                        alignment: Alignment.topCenter,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage("images/bebe_auto_clip.jpg"),
                                radius: 100,
                              ),
                              Text("Sem dados disponiveis"),
                            ]));
                  }
                })));

  }

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Container(
            color: Colors.grey,
            child: LayoutGrid(
                // ASCII-art named areas 🔥
                areas: '''
                  s h
                  s l     
                  s g   
                  s g
                  s c 
                ''',
                // Concise track sizing extension methods 🔥
                columnSizes: [0.7.fr, 3.8.fr],
                rowSizes: [
                  0.2.fr,
                  0.1.fr,
                  1.0.fr,
                  1.8.fr,
                  1.2.fr,
                ],
                // Column and row gaps! 🔥
                columnGap: 0,
                rowGap: 0,
                // Handy grid placement extension methods on Widget 🔥
                children: [
                  gridArea('s').containing(Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 10)),
                      child: menuGrid())),
                  gridArea('c').containing(
                    cards(),
                  ),
                  gridArea('g').containing(graph()),
                  gridArea('l').containing(Container(
                    color: Colors.black,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                      children:[
                        Text("Grafico Histórico de    ",style: const TextStyle(color: Colors.white,fontSize: 12)),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text("Temperatura     ", style: const TextStyle(color: Colors.white,fontSize: 12)),

                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: const BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text("Humidade     ", style: const TextStyle(color: Colors.white,fontSize: 12)),
                      ]
                    )
                  )),
                  gridArea('h').containing(Container(
                      color: Colors.black,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text("Painel",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)),
                            )
                          ]))),
                ])));
  }

  Card makeDashboardItem(
      String title, String subtitle, Color color, String imagePath) {
    return Card(
        elevation: 2,
        color: color,
        clipBehavior: Clip.hardEdge,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              color: Colors.white38,
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(20),
              )),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: Alignment.topCenter,
                  child: CircleAvatar(
                    backgroundImage: AssetImage(imagePath),
                    radius: 35,
                  ),
                ),
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
        time =
            'HÁ' + (diff.inDays / 7).floor().toString() + ' SEMANA(S) \nATRÁS';
      } else {
        time =
            'HÁ ' + (diff.inDays / 7).floor().toString() + ' SEMANA(S) \nATRÁS';
      }
    }

    return time;
  }
}
