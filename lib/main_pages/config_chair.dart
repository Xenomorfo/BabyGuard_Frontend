import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/main_pages/dash_web.dart';
import 'dart:convert';

import 'package:myapp/main_pages/dashboard.dart';

class Configchair extends StatefulWidget {
  final user;
  final Widget? sidebar;

  const Configchair({super.key, required this.user, this.sidebar});

  @override
  State<Configchair> createState() => _ConfigchairState();
}

class _ConfigchairState extends State<Configchair> {
  TextEditingController serial = TextEditingController();
  TextEditingController emergency_1 = TextEditingController();
  TextEditingController emergency_2 = TextEditingController();
  TextEditingController emergency_3 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future configChair() async {
    var url = "http://xenomorfo.ddns.net:3000/configs";
    Map data = {
      "email": widget.user["email"],
      "serial": widget.user["serial"],
      "contact_1": widget.user["emergency_1"],
      "contact_2": int.parse(emergency_2.text),
      "contact_3": int.parse(emergency_3.text),
    };
    widget.user["serial"] = serial.text;
    widget.user["emergency_1"] = emergency_1.text;
    widget.user["emergency_2"] = emergency_2.text;
    widget.user["emergency_3"] = emergency_3.text;
    ;
    // Encode Map to JSON
    var body = json.encode(data);
    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);

    var userData = json.decode(response.body);
    debugPrint(userData['msg']);
    if (userData['msg'] == 'User not found') {
      _showDialog(context, "Utilizador Inválido", "ATENÇÃO", Colors.red);
    } else {
      _showDialog(context, "Editado com sucesso", "Mensagem", Colors.lightBlue);
    }
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
        title: Center(
            child: Text(title)
        ),
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

  @override
  void initState() {
    super.initState();

    if (widget.user["id"] != null) {
      if (serial.text.isEmpty) serial.text = widget.user["serial"];
      if (emergency_1.text.isEmpty)
        emergency_1.text = widget.user["emergency_1"].toString();
      if (emergency_2.text.isEmpty)
        emergency_2.text = widget.user["emergency_2"].toString();
      if (emergency_3.text.isEmpty)
        emergency_3.text = widget.user["emergency_3"].toString();
      ;
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 640)
    return Scaffold(
        appBar: AppBar(
          title: Text('Editar Contactos'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
          Positioned(
          top: 0,
          child:Align(
              alignment: Alignment.topCenter,
              child: CircleAvatar(
                backgroundImage: AssetImage("images/bebe_auto_clip.jpg"),
                radius: 100,
              ),
            ),
          ),
            Positioned(
              top: 240,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  // this to show error when user is in some textField
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          readOnly: true,
                          controller: serial,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.numbers_outlined),
                            labelText: "Número de Serie",
                            hintText: widget.user["serial"],
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          readOnly: true,
                          controller: emergency_1,
                          /*keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            // for below version 2 use this
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            // for version 2 and greater youcan also use this
                            FilteringTextInputFormatter.digitsOnly
                          ],*/
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            hintText: widget.user["emergency_1"].toString(),
                            labelText: "Contacto Principal",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: emergency_2,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            // for below version 2 use this
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            // for version 2 and greater youcan also use this
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            hintText: widget.user["emergency_2"].toString(),
                            labelText: "Contacto Secundário 1",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira um contacto válido!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: emergency_3,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            // for below version 2 use this
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            // for version 2 and greater youcan also use this
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            hintText: widget.user["emergency_3"].toString(),
                            labelText: "Contacto Secundário 2",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira um contacto válido!';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 540,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      color: Colors.lightBlue,
                      child: Text(
                        "Atualizar",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) configChair();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Dashboard(user: widget.user)),
                        );
                      },
                    )),
              ),
            ),
          ],
        ));
    else  return Scaffold(
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
    gridArea('l')
        .containing(Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 50,
              child:Align(
                alignment: Alignment.topCenter,
                child: CircleAvatar(
                  backgroundImage: AssetImage("images/bebe_auto_clip.jpg"),
                  radius: 100,
                ),
              ),
            ),
            Positioned(
              top: 280,
              child: Container(
                width: 600,
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  // this to show error when user is in some textField
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          readOnly: true,
                          controller: serial,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                            OutlineInputBorder(borderSide: BorderSide()),
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.numbers_outlined),
                            labelText: "Número de Serie",
                            hintText: widget.user["serial"],
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          readOnly: true,
                          controller: emergency_1,
                          /*keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            // for below version 2 use this
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            // for version 2 and greater youcan also use this
                            FilteringTextInputFormatter.digitsOnly
                          ],*/
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                            OutlineInputBorder(borderSide: BorderSide()),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            hintText: widget.user["emergency_1"].toString(),
                            labelText: "Contacto Principal",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: emergency_2,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            // for below version 2 use this
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            // for version 2 and greater youcan also use this
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                            OutlineInputBorder(borderSide: BorderSide()),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            hintText: widget.user["emergency_2"].toString(),
                            labelText: "Contacto Secundário 1",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira um contacto válido!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20.0),
                        TextFormField(
                          controller: emergency_3,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            // for below version 2 use this
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            // for version 2 and greater youcan also use this
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                            OutlineInputBorder(borderSide: BorderSide()),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            hintText: widget.user["emergency_3"].toString(),
                            labelText: "Contacto Secundário 2",
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira um contacto válido!';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 580,
              child: Container(
                width: 100,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      color: Colors.lightBlue,
                      child: Text(
                        "Atualizar",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) configChair();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Dashweb(user: widget.user)),
                        );
                      },
                    )),
              ),
            ),
          ],
        )
    ),
          gridArea('h').containing(
              Container(
                  color: Colors.black,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text("Configurar Contactos",
                              style: TextStyle(
                                  fontSize: 20, color: Colors.white)),
                        )
                      ]
                  )
              )
          )
        ]));
  }
}
