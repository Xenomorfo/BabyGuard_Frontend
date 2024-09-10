import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/main_pages/login.dart';
import 'dart:convert';

class ReporPassword extends StatefulWidget {
  const ReporPassword({super.key});

  @override
  State<ReporPassword> createState() => _ReporPasswordState();
}

class _ReporPasswordState extends State<ReporPassword> {
  TextEditingController email = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future reporPassword() async {
    var url = "http://xenomorfo.ddns.net:3000/requestpass";

    Map data = {"email": email.text};

    // Encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);

    var userData = json.decode(response.body);

    if (userData['msg'] == 'User not found') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erro"),
          content: Text("Este email não está associado a uma conta"),
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Mensagem"),
          content: Text("Email com nova senha enviado com sucesso!"),
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
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 640)
    return Scaffold(
        appBar: AppBar(
          title: Text('Repor Password'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 50,
              child: Align(
                alignment: Alignment.topCenter,
                child: CircleAvatar(
                  backgroundImage: AssetImage("images/bebe_auto_clip.jpg"),
                  radius: 100,
                ),
              ),
            ),
            Positioned(
              top:  240,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction, // this to show error when user is in some textField
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: email,
                    decoration: InputDecoration(enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.blueGrey, width: 2.0)),
                        border:
                        OutlineInputBorder(borderSide: BorderSide()),
                        hintStyle: TextStyle(fontStyle: FontStyle.italic),
                        fillColor: Colors.white,
                        filled: true,
                        prefixIcon: Icon(Icons.email_outlined),
                        labelStyle: TextStyle(fontStyle: FontStyle.italic),
                         labelText: 'E-mail Para Repor a Senha'
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Insira um e-mail válido!';
                      }
                      return null;
                    },
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
                        "Repor",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if(_formKey.currentState!.validate()) reporPassword();
                      },
                    )),
              ),
            ),

          ],
        ));
    else return Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 50,
              child: Align(
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
                  autovalidateMode: AutovalidateMode.onUserInteraction, // this to show error when user is in some textField
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: email,
                      decoration: InputDecoration(enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.blueGrey, width: 2.0)),
                          border:
                          OutlineInputBorder(borderSide: BorderSide()),
                          hintStyle: TextStyle(fontStyle: FontStyle.italic),
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(Icons.email_outlined),
                          labelStyle: TextStyle(fontStyle: FontStyle.italic),
                          labelText: 'E-mail Para Repor a Senha'
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Insira um e-mail válido!';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 400,
              child: Container(
                width: 600,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      color: Colors.lightBlue,
                      child: Text(
                        "Repor",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        if(_formKey.currentState!.validate()) reporPassword();
                      },
                    )),
              ),
            ),

              Positioned(
                top: 460,
                child: Container(
                  width: 600,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        color: Colors.lightBlue,
                        child: Text(
                          "Voltar",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )),
                ),
              ),
          ],
        ));
  }
}
