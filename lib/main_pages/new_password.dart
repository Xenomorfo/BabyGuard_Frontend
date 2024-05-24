import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/main_pages/login.dart';
import 'dart:convert';

class NovaPassword extends StatefulWidget {
  final user;
  const NovaPassword({super.key, required this.user});


  @override
  State<NovaPassword> createState() => _NovaPasswordState();
}

class _NovaPasswordState extends State<NovaPassword> {
  TextEditingController password = TextEditingController();
  TextEditingController conf_password = TextEditingController();
  bool passwordVisible = true;
  bool confirmPasswordVisible = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  verifica_password() {
    if (password.text == conf_password.text) {
      updatePassword();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erro"),
          content: Text("As password não correspondem"),
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
  }

  Future updatePassword() async {
    var url = "http://xenomorfo.ddns.net:3000/updatepass";
    Map data = {
      "id": widget.user['id'],
      "password": password.text
    };
    // Encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);

    var userData = json.decode(response.body);

    if (userData['msg'] == 'error') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erro"),
          content: Text("O token expirou, tente repor novamente a password"),
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
          content: Text("Password atualizada com sucesso"),
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
          title: Text('Nova Senha'),
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
                  'Nova Senha',
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
                      child: Column(
                      children:<Widget> [ TextFormField(
                        obscureText: passwordVisible,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: password,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          suffixIcon: IconButton(
                          icon: Icon(passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(
                                  () {
                                passwordVisible = !passwordVisible;
                              },
                            );
                          })
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira uma senha válida!';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        obscureText: confirmPasswordVisible,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: conf_password,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          suffixIcon: IconButton(
                              icon: Icon(confirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(
                                      () {
                                    confirmPasswordVisible = !confirmPasswordVisible;
                                  },
                                );
                              })
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira uma confirmação válida!';
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
              top: 380,
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
                        if(_formKey.currentState!.validate()) verifica_password();
                      },
                    )),
              ),
            ),
          ],
        ));
  }
}
