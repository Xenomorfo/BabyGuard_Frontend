import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/pages/login.dart';
import 'dart:convert';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirm = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController contact = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future signUp() async {
    var url = "http://xenomorfo.ddns.net:3000/adduser";

    Map data = {
      "name": name.text,
      "email": email.text,
      "password": password.text,
      "contact": contact.text
    };

    // Encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);

    var userData = json.decode(response.body);
    debugPrint(response.body);
    if (userData['msg'] == 'Already taken') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erro"),
          content: Text("Já existe um utilizador registado com este email"),
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
    } else if (password.text != confirm.text) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erro"),
          content: Text("Senha e confirmação diferentes"),
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
          content: Text("Registado com sucesso"),
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
          title: Text('Registar'),
        ),
        body: Stack(
            children: [
              Container(
                color: Colors.grey[100],
              ),
              Positioned(
                top: 20,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Registar',
                    style: TextStyle(fontFamily: 'Bebas', fontSize: 30),
                  ),
                ),
              ),
              Positioned(
                top: 60,
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
                            controller: email,
                            decoration: InputDecoration(
                              labelText: 'Email',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Insira um e-mail válido!';
                              }
                              return null;
                            },
                         ),
                        TextFormField(
                          controller: name,
                          decoration: InputDecoration(
                            labelText: 'Nome',
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
                            labelText: 'Contato',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira um contato válido!';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: password,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty ) {
                              return 'Insira uma senha válida!';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: confirm,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Senha',
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
                top: 430,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        color: Colors.lightBlue,
                        child: Text(
                          "Registar",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if(_formKey.currentState!.validate()) signUp();
                        },
                      )),
                ),
              ),
              Positioned(
                top: 470,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      child: Text(
                        "Já registado? Faça Login",
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        //debugPrint("login");

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
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
