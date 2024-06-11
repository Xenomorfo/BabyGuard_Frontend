import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:myapp/main_pages/dashboard.dart';

class Editprofile extends StatefulWidget {

  final user;

  const Editprofile({super.key, required this.user});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  TextEditingController name = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController serial = TextEditingController();
  final _formKey = GlobalKey<FormState>();


  Future editProfile() async {
    var url = "http://xenomorfo.ddns.net:3000/editprofile";
    Map data = {
      "name": name.text,
      "contact": int.parse(contact.text),
      "email": widget.user["email"],
      "serial": serial.text
    };
    widget.user["email"] = data["email"];
    widget.user["contact"] = data["contact"];
    widget.user["name"] = data["name"];

    widget.user["emergency_1"] = data["contact"];
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
    } else if (userData['msg'] == 'Serial already taken') {
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              title: Text("Erro"),
              content: Text("Essa cadeira já existe. Alteração anulada."),
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
      widget.user["serial"] = data["serial"];
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
      if(name.text.isEmpty) name.text=widget.user["name"];
      if(contact.text.isEmpty) contact.text=widget.user["contact"].toString();
      if(serial.text.isEmpty) serial.text=widget.user["serial"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Editar Perfil'),
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
                  'Editar Perfil',
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
                        controller: email,
                        decoration: InputDecoration(
                          labelText: "E-mail",
                          hintText: widget.user["email"],
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),

                      ),
                      TextFormField(
                        controller: name,
                        decoration: InputDecoration(
                          hintText: widget.user["name"],
                          labelText: "Name",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira um nome válido!';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                          controller: contact,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            // for below version 2 use this
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                            // for version 2 and greater youcan also use this
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            hintText: widget.user["contact"].toString(),
                            labelText: "Contacto",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira um contacto válido!';
                            }
                            return null;
                          },
                        ),

                  TextFormField(
                    controller: serial,
                    decoration: InputDecoration(
                      hintText: widget.user["serial"],
                      labelText: "Número de Série da Cadeira",

                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 10) {
                        return 'Insira um número de série válido!';
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
              top: 430,
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
                        if(_formKey.currentState!.validate()) editProfile();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Dashboard(
                                   user: widget.user)),
                        );
                      },
                    ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
