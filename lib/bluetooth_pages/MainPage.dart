import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/bluetooth_connection/flutter_bluetooth_serial.dart';
import 'package:location/location.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';


class MainPage extends StatefulWidget {
  final user;
  final conn;
  final BluetoothDevice? server;


  const MainPage({this.user, this.conn, this.server});
  @override
  _MainPage createState() => new _MainPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  Location location = Location();
  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  String _address = "...";
  String _name = "...";

  BluetoothConnection? connection;

  static final clientID = 0;
  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';


  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {

    super.initState();

    BluetoothConnection.toAddress(widget.server?.address).then((_connection) {
      print('Connected to the device: '+widget.server!.address.toString());
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input?.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });


    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name!;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração Bluetooth'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            ListTile(title: const Text('Geral')),
            SwitchListTile(
              title: const Text('Ativar Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value) {
                    await FlutterBluetoothSerial.instance.requestEnable();
                    location.enableBackgroundMode();
                  }
                  else {
                    await FlutterBluetoothSerial.instance.requestDisable();
                  }
                }

                future().then((_) {
                  setState(() {});
                });
              },
            ),
            ListTile(
              title: const Text('Estado do Bluetooth'),
              subtitle: Text(_bluetoothState.toString()),
              trailing: ElevatedButton(
                child: const Text('Configurações'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            ListTile(
              title: const Text('Adaptador endereço local'),
              subtitle: Text(_address),
            ),
            ListTile(
              title: const Text('Nome adaptador local'),
              subtitle: Text(_name),
              onLongPress: null,
            ),
            Divider(),
            ListTile(title: const Text('Dispositivos descobertos e ligação')),
            ListTile(
              title: ElevatedButton(
                  child: const Text('Procurar dispositivos'),
                  onPressed: () async {
                    final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return DiscoveryPage();
                        },
                      ),
                    );

                    if (selectedDevice != null &&
                        selectedDevice.name == "BabyGuard") {
                      BluetoothConnection.toAddress(selectedDevice.address)
                          .then((_connection) async {
                        connection = _connection;
                        print('Connected to the device');
                        print('ligado: ' + connection!.isConnected.toString());


                      }).catchError((error) async {
                        await Future.delayed(const Duration(seconds: 3));
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: Text("Ligação Bluetooth"),
                                content: Text("Desligado da cadeira"),
                                actions: [
                                  MaterialButton(
                                    color: Colors.lightBlue,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Ok"),
                                  )
                                ],
                              ),
                        );

                      });

                    }
                  }),
            ),
            ListTile(
              title: ElevatedButton(
                child: const Text('Ligar/desligar a dispostivo'),
                onPressed: () async {
                  final BluetoothDevice? selectedDevice =
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return SelectBondedDevicePage(checkAvailability: false);
                      },
                    ),
                  );

                  if (selectedDevice != null &&
                      selectedDevice.name == "BabyGuard") {
                    print('Ligado -> selecionado ' + selectedDevice.address);

                    BluetoothConnection.toAddress(selectedDevice.address)
                        .then((_connection) async {
                      connection = _connection;
                      print('Connected to the device');
                      print('ligado: ' + connection!.isConnected.toString());
                    }).catchError((error) async {
                      await Future.delayed(const Duration(seconds: 3));
                        showDialog(
                          context: context,
                          builder: (context) =>
                              AlertDialog(
                                title: Text("Ligação Bluetooth"),
                                content: Text("Desligado da cadeira"),
                                actions: [
                                  MaterialButton(
                                    color: Colors.lightBlue,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Ok"),
                                  )
                                ],
                              ),
                        );

                    });

                  }
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(10);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
        print(dataString);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();

    if (text.length > 0) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode(text + "\r\n")));
        await connection!.output.allSent;

        setState(() {
          messages.add(_Message(clientID, text));
        });

        /*Future.delayed(Duration(milliseconds: 333)).then((_) {
          listScrollController.animateTo(
              listScrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 333),
              curve: Curves.easeOut);
        });*/
        print("message sent: "+text);
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }


}
