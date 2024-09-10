import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/main_pages/dash_web.dart';
import 'dart:convert';

import 'package:myapp/main_pages/dashboard.dart';

class Editprofile extends StatefulWidget {

  final user;
  final Widget? sidebar;

  const Editprofile({super.key, required this.user, this.sidebar});

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
      if (name.text.isEmpty) name.text = widget.user["name"];
      if (contact.text.isEmpty)
        contact.text = widget.user["contact"].toString();
      if (serial.text.isEmpty) serial.text = widget.user["serial"];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery
        .of(context)
        .size
        .width < 640)
      return Scaffold(
        appBar: AppBar(
          title: Text('Editar Perfil'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              child: Align(
                child: CircleAvatar(
                  backgroundImage: AssetImage("images/bebe_auto_clip.jpg"),
                  radius: 100,
                ),
              ),
            ),
            Positioned(
              top: 240,
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,

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
                          controller: email,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0
                                )
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide()),
                            hintStyle: TextStyle(fontWeight: FontWeight.bold),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.email_outlined),
                            labelText: "E-mail",
                            hintText: widget.user["email"],
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                          ),

                        ),
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: name,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0
                                )
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide()),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.account_box_outlined),
                            hintText: widget.user["name"],
                            hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            labelText: "Nome",
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira um nome válido!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8.0),
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

                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0
                                )
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide()),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.phone_outlined),
                            hintText: widget.user["contact"].toString(),
                            labelText: "Contacto",
                            hintStyle: TextStyle(fontStyle: FontStyle.italic,
                                color: Colors.red),

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
                          controller: serial,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0
                                )
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide()),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.numbers_outlined),
                            hintStyle: TextStyle(fontStyle: FontStyle.italic),
                            hintText: widget.user["serial"],
                            labelText: "Número de Série da Cadeira",

                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty ||
                                value.length < 10) {
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
              top: 540,
              child: Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    color: Colors.lightBlue,
                    child: Text(
                      "Atualizar",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) editProfile();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Dashboard(
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
    else
      return Scaffold
        (
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
                child: Align(
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
                            controller: email,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 2.0
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide()),
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.email_outlined),
                              labelText: "E-mail",
                              hintText: widget.user["email"],
                              floatingLabelBehavior: FloatingLabelBehavior
                                  .always,
                            ),

                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            controller: name,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 2.0
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide()),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.account_box_outlined),
                              hintText: widget.user["name"],
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                              labelText: "Nome",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Insira um nome válido!';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0),
                          TextFormField(
                            controller: contact,
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              // for below version 2 use this
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9]')),
                              // for version 2 and greater youcan also use this
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(

                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 2.0
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide()),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.phone_outlined),
                              hintText: widget.user["contact"].toString(),
                              labelText: "Contacto",
                              hintStyle: TextStyle(fontStyle: FontStyle.italic,
                                  color: Colors.red),

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
                            controller: serial,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 2.0
                                  )
                              ),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide()),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.numbers_outlined),
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                              hintText: widget.user["serial"],
                              labelText: "Número de Série da Cadeira",

                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty ||
                                  value.length < 10) {
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
                        if (_formKey.currentState!.validate()) editProfile();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Dashweb(
                                      user: widget.user)),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
          gridArea('h').containing(
            Container(
                color: Colors.black,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Text("Editar Perfil",
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
