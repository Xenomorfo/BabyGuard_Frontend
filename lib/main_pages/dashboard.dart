import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:myapp/bluetooth_pages/MainPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:myapp/main_pages/config_chair.dart';
import 'package:myapp/main_pages/edit_profile.dart';
import 'package:myapp/main_pages/login.dart';
import 'dart:convert';
import 'package:myapp/main_pages/new_password.dart';
import 'package:vibration/vibration.dart';
import 'history.dart';
import 'map.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:myapp/services/notify_service.dart';

class Dashboard extends StatefulWidget {
  final user;
  BluetoothConnection? device;
  String? rssi;

  Dashboard({super.key, required this.user, this.device});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool isConnected = false;
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? timer;

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
    widget.user['seat'] = jsonDecode(response.body)['events']['seat'];
    widget.user['car'] = jsonDecode(response.body)['events']['car'];
    widget.user['belt'] = jsonDecode(response.body)['events']['belt'];
    widget.user['temp'] = jsonDecode(response.body)['events']['temperature'];
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
    if (mounted)
      Timer.periodic(Duration(seconds: 5), (Timer t) {
        _streamSubscription!.cancel();
        FlutterBluetoothSerial.instance.cancelDiscovery();
        if (mounted)
          setState(() {
            build(context);
            _streamSubscription = FlutterBluetoothSerial.instance
                .startDiscovery()
                .listen((event) {
              if (event.device.name == 'BabyGuard' && !event.device.isConnected)
                connection(event.device.address);
              else if (event.device.name == 'BabyGuard' &&
                  event.device.isConnected) {
                if (event.rssi.toInt() < -90 && widget.user["seat"] == 1
                && widget.user['car'] == 1) {
                  NotificationService().showNotification(
                      title: "ATENÇÃO", body: "Criança presente na cadeira!!");
                  Vibration.vibrate(pattern: [500, 1000, 500, 2000]);
                  _showDialog(context, "Criança presente na cadeira!!",
                      "ATENÇÃO", Colors.red);
                  FlutterBeep.playSysSound(45);

                } else if (event.rssi.toInt() < -90 && widget.user["seat"] == 1
                && widget.user['belt'] == 0) {
                  NotificationService().showNotification(
                      title: "ATENÇÃO", body: "Criança não segura na cadeira!!");
                  Vibration.vibrate(pattern: [500, 1000, 500, 2000]);
                  _showDialog(context, "Criança não segura na cadeira!!",
                      "ATENÇÃO", Colors.red);
                  FlutterBeep.playSysSound(45);
                }
                else if (event.rssi.toInt() < -90 && widget.user["seat"] == 1
                    && widget.user['belt'] == 1 && widget.user['temp'] > 35) {
                  NotificationService().showNotification(
                      title: "ATENÇÃO", body: "Criança sob intenso calor na cadeira!!");
                  Vibration.vibrate(pattern: [500, 1000, 500, 2000]);
                  _showDialog(context, "Criança sob intenso calor na cadeira!!",
                      "ATENÇÃO", Colors.red);
                  FlutterBeep.playSysSound(45);
                }
              }
              /*debugPrint(event.rssi.toString());
              debugPrint(widget.user['seat'].toString());
              debugPrint(widget.user['car'].toString());
              debugPrint(widget.user['belt'].toString());
              debugPrint(widget.user['temp'].toString());*/
            });
          });
      });
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    if (widget.device?.isConnected == null) {
      isConnected = false;
      blue_control();
    } else if (!widget.device!.isConnected) {
      isConnected = false;
      blue_control();
    } else {
      isConnected = true;
    }
  }

  // Bluetooth connection dashboard
  Future<void> blue_control() async {
    if (!isConnected && widget.user["serial"] != 0) {
      _streamSubscription = await FlutterBluetoothSerial.instance
          .startDiscovery()
          .listen((r) async {
        if (r.device.name == 'BabyGuard') connection(r.device.address);
        _streamSubscription?.cancel();
      });
      _streamSubscription!.onDone(() {
        if (mounted)
          setState(() {
            isConnected = false;
          });
      });
    }
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription!.cancel();
    widget.device?.close();
    timer?.cancel();
    super.dispose();
  }

  Future<void> connection(address) async {
    await BluetoothConnection.toAddress(address).then((_connection) {
      print('Connected to the device: ' + address.toString());
      isConnected = _connection.isConnected;
      widget.device = _connection;
      debugPrint(widget.device.toString());
      if (isConnected) {
        _connection.output.add(
            Uint8List.fromList(utf8.encode(widget.user["serial"].toString())));
        _showDialog(
            context,
            "Cadeira " + widget.user["serial"].toString() + " ativada",
            "Ligação Bluetooth",
            Colors.lightBlue);
        _connection.input!.listen((_onDataReceived) {
          if (String.fromCharCodes(_onDataReceived).substring(0, 2) == 'No') {
            _showDialog(
                context,
                "Cadeira " +
                    widget.user["serial"].toString() +
                    " não autorizada",
                "Ligação Bluetooth",
                Colors.lightBlue);

            isConnected = false;
          } else if (String.fromCharCodes(_onDataReceived).substring(0, 2) ==
              'sl') {
            print(String.fromCharCodes(_onDataReceived).substring(0, 2));

            _showDialog(
                context,
                "Cadeira " +
                    widget.user["serial"].toString() +
                    " em modo Standby",
                "Ligação Bluetooth",
                Colors.lightBlue);

            isConnected = false;
          } else if (String.fromCharCodes(_onDataReceived).substring(0, 2) ==
              'Au') {
            Timer(Duration(seconds: 5), () {
              _showDialog(
                  context,
                  "Cadeira " + widget.user["serial"].toString() + " ativada",
                  "Ligação Bluetooth",
                  Colors.lightBlue);
            });
            isConnected = true;
          }
        }).onDone(() {
          Timer(Duration(seconds: 5), () {
            _showDialog(
                context,
                "Cadeira " + widget.user["serial"].toString() + " desligada",
                "Ligação Bluetooth",
                Colors.lightBlue);
          });
          isConnected = false;
        });
      }
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
      isConnected = false;
      _showDialog(
          context,
          "Verifique a cadeira " + widget.user["serial"].toString(),
          "Ligação Bluetooth",
          Colors.lightBlue);
    });
  }

  Future<dynamic> _showDialog(
      BuildContext context, String status, String title, Color color) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close the dialog
    });
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Center(child: Text(title)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              'images/bebe_auto_clip.jpg', // Replace with your image path
              width: 70, // Adjust image width as needed
            ),
            SizedBox(height: 5), // Adjust spacing as needed
            Text(status),
          ],
        ),
      ),
    );
  }

  Widget menuDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.lightBlue),
            currentAccountPicture: GestureDetector(
                child: CircleAvatar(
              backgroundImage: AssetImage("images/bebe_auto_clip.jpg"),
            )),
            accountName: Text(widget.user["name"]),
            accountEmail: Text(''),
          ),
          ListTile(
            onTap: () {
              Navigator.pop(context);
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
                      builder: (context) => Maps(user: widget.user),
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
                  builder: (context) =>
                      History(user: widget.user, allData: getAll()),
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
                  builder: (context) => Editprofile(user: widget.user),
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
                  builder: (context) => Configchair(user: widget.user),
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
              //debugPrint("dashboard");
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainPage(user: widget.user),
                ),
              );
            },
            leading: Icon(Icons.bluetooth),
            title: Text(
              'Bluetooth',
              style: TextStyle(color: Colors.blue.shade900),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NovaPassword(user: widget.user),
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
                                  _streamSubscription!.cancel(),
                                  widget.device?.close(),
                                  timer?.cancel(),
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
                                    WidgetStateProperty.all(Colors.blue),
                                foregroundColor:
                                    WidgetStateProperty.all(Colors.white)),
                            child: Text('Sim')),
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.blue),
                                foregroundColor:
                                    WidgetStateProperty.all(Colors.white)),
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

  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(title: Text('Painel')),
          drawer: menuDrawer(),
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
                        crossAxisCount: 2,
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
                                Color.fromRGBO(250, 0, 0, 1.0),
                                "images/baby-car-seat.png")
                          else
                            makeDashboardItem(
                                'Ausente',
                                'Criança',
                                Color.fromRGBO(0, 150, 0, 1.0),
                                "images/no-baby-car-seat.png"),
                          // Cinto de segurança
                          if (snapshot.data['events']['belt'] == 1)
                            makeDashboardItem(
                                'Fechado',
                                'Cinto',
                                Color.fromRGBO(250, 0, 0, 1.0),
                                "images/belt.png")
                          else
                            makeDashboardItem(
                                'Aberto',
                                'Cinto',
                                Color.fromRGBO(222, 215, 25, 1.0),
                                "images/no-belt.png"),
                          // Estado portas da viatura
                          if (snapshot.data['events']['car'] == 1)
                            makeDashboardItem(
                                'Fechada',
                                'Viatura',
                                Color.fromRGBO(250, 0, 0, 1.0),
                                "images/door-closed.png")
                          else
                            makeDashboardItem(
                                'Aberta',
                                'Viatura',
                                Color.fromRGBO(0, 150, 0, 1.0),
                                "images/door-open.png"),
                          // Dados GPS
                          if (snapshot.data['events']['lat'] == 0.1 &&
                              snapshot.data['events']['long'] == 0.1)
                            makeDashboardItem(
                                'Sem informação',
                                'Localização',
                                Color.fromRGBO(250, 0, 0, 1.0),
                                "images/map.png")
                          else
                            makeDashboardItem(
                                snapshot.data['events']['lat'].toString() +
                                    "\n " +
                                    snapshot.data['events']['long'].toString(),
                                'Localização',
                                Color.fromRGBO(0, 150, 0, 1.0),
                                "images/map.png"),
                          // Dados do Bluetooth
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
                    child: Column(children: [
                      CircleAvatar(
                        backgroundImage:
                            AssetImage("images/bebe_auto_clip.jpg"),
                        radius: 100,
                      ),
                      SizedBox(height: 8.0),
                      Text("Sem dados disponiveis"),
                    ]));
              }
            },
          ),
        ));
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
