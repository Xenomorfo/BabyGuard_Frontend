import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:myapp/pages/dashboard.dart';

class Configchair extends StatefulWidget {
  final user;

  const Configchair({super.key, required this.user});

  @override
  State<Configchair> createState() => _ConfigchairState();
}

class _ConfigchairState extends State<Configchair> {
  TextEditingController serial = TextEditingController();
  TextEditingController emergency_1 = TextEditingController();
  TextEditingController emergency_2 = TextEditingController();
  TextEditingController emergency_3 = TextEditingController();
  TextEditingController sim = TextEditingController();
  final _formKey = GlobalKey<FormState>();




  Future configChair() async {
    var url = "http://xenomorfo.ddns.net:3000/configs";
    Map data = {
      "email": widget.user["email"],
      "serial": widget.user["serial"],
      "contact_1": widget.user["emergency_1"],
      "contact_2": int.parse(emergency_2.text),
      "contact_3": int.parse(emergency_3.text),
      "sim": sim.text,
    };
    widget.user["serial"] = serial.text;
    widget.user["emergency_1"] = emergency_1.text;
    widget.user["emergency_2"] = emergency_2.text;
    widget.user["emergency_3"] = emergency_3.text;
    widget.user["sim"] = sim.text;
    // Encode Map to JSON
    var body = json.encode(data);
    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);

    var userData = json.decode(response.body);
    debugPrint(userData['msg']);
    if (userData['msg'] == 'User not found') {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Erro"),
              content: Text("Utilizador Inválido"),
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
    } else {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Mensagem"),
              content: Text("Editado com sucesso"),
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
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.user["id"] != null) {
      if(serial.text.isEmpty) serial.text=widget.user["serial"];
      if(emergency_1.text.isEmpty) emergency_1.text=widget.user["emergency_1"].toString();
      if(emergency_2.text.isEmpty) emergency_2.text=widget.user["emergency_2"].toString();
      if(emergency_3.text.isEmpty) emergency_3.text=widget.user["emergency_3"].toString();
      if(sim.text.isEmpty) sim.text=widget.user["sim"];
    };
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Cadeira'),
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.grey[100],
            ),
            Positioned(
              top: 80,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Configuração da Cadeira',
                  style: TextStyle(fontFamily: 'Bebas', fontSize: 30),
                ),
              ),
            ),
            Positioned(
              top: 120,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Form(
                  autovalidateMode: AutovalidateMode.onUserInteraction, // this to show error when user is in some textField
                  key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column (
                    children:<Widget> [
                  TextFormField(
                    readOnly: true,
                    controller: serial,
                    decoration: InputDecoration(
                      labelText: "Número de Serie",
                      hintText: widget.user["serial"].toString(),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),

                  ),

                  TextFormField(
                    readOnly: true,
                    controller: emergency_1,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      // for below version 2 use this
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                      // for version 2 and greater youcan also use this
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                      hintText: widget.user["emergency_1"].toString(),
                      labelText: "Contacto Principal",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),

                  ),
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

                  TextFormField(
                    controller: sim,
                    decoration: InputDecoration(
                      hintText: widget.user["sim"].toString(),
                      labelText: "PIN do SimCard",
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira um sim PIN válido!';
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
              top: 500,
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
                        if(_formKey.currentState!.validate()) configChair();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Dashboard(
                                  user: widget.user)
                          ),
                        );
                        },
                    )
                ),
              ),
            ),
          ],
        )
    );
  }
}
