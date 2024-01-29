import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/pages/login.dart';
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
    var url = "http://192.168.1.5:3000/requestpass";

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
    return Scaffold(
        appBar: AppBar(
          title: Text('Repor Password'),
        ),
        body: Stack(
          children: [
            Container(
              color: Colors.grey[100],
            ),
            Positioned(
              top: 100,

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Repor Password',
                  style: TextStyle(fontFamily: 'Bebas', fontSize: 30),
                ),
              ),
            ),
            Positioned(
              top: 190,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction, // this to show error when user is in some textField
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: email,
                    decoration: InputDecoration(
                      labelText: 'Insira o E-mail Para Repor a Senha'
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
              top: 300,
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
  }
}
