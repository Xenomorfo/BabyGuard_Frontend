import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:myapp/pages/dashboard.dart';

class Editprofile extends StatefulWidget {
  final id;
  final name;
  final email;
  final contact;
  final password;
  final token;

  const Editprofile({super.key, required this.id, this.name, this.email, this.contact, this.password, required this.token});

  @override
  State<Editprofile> createState() => _EditprofileState();
}

class _EditprofileState extends State<Editprofile> {
  TextEditingController name = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController email = TextEditingController();


  Future editProfile() async {
    var url = "http://192.168.1.5:3000/editprofile";
    if (name.text.isEmpty) name.text = widget.name;
    if (contact.text.isEmpty) contact.text = widget.contact;
    Map data = {
      "name": name.text,
      "contact": contact.text,
      "email": widget.email
    };

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
    if (widget.id != null) {
      if(name.text.isEmpty) name.text=widget.name;
      if(contact.text.isEmpty) contact.text=widget.contact;
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    readOnly: true,
                    controller: email,
                    decoration: InputDecoration(
                      labelText: "E-mail",
                      hintText: widget.email,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 190,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                      hintText: widget.name,
                      labelText: "Name",
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 260,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: contact,
                    decoration: InputDecoration(
                      hintText: widget.contact,
                      labelText: "Contacto",

                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 400,
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
                        editProfile();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Dashboard(
                                    id: widget.id, name: name.text, email: widget.email, contact: contact.text, password: widget.password, token: widget.token)
                          ),
                        );

                      },
                    )),
              ),
            ),
          ],
        ));
  }
}
