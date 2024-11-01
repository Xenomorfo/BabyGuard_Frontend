import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/main_pages/login.dart';
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
  bool passwordVisible = true;
  bool confirmPasswordVisible = true;

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
      _showDialog(context, "Já existe um utilizador registado com este email",
          "ATENÇÃO", Colors.red);
    } else if (password.text != confirm.text) {
      _showDialog(context, "Senha e confirmação diferentes",
          "ATENÇÃO", Colors.red);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
      );
      _showDialog(context, "Registado com sucesso",
          "Mensagem", Colors.lightBlue);
    }
  }

  Future<dynamic> _showDialog(
      BuildContext context, String status, String title, Color color) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Close the dialog
    });
    return showDialog(
      context: context,
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
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width < 640)
    return Scaffold(
      appBar: AppBar(
        title: Text('Registar'),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Align(
              child: CircleAvatar(
                backgroundImage: AssetImage("images/bebe_auto_clip.jpg"),
                radius: 70,
              ),
            ),
          ),
          Positioned(
            top: 140,
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
                        controller: email,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueGrey, width: 2.0)),
                          border: OutlineInputBorder(borderSide: BorderSide()),
                          labelStyle: TextStyle(fontStyle: FontStyle.italic),
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira um e-mail válido!';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        controller: name,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueGrey, width: 2.0)),
                          border: OutlineInputBorder(borderSide: BorderSide()),
                          labelStyle: TextStyle(fontStyle: FontStyle.italic),
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(Icons.person_2_outlined),
                          labelText: 'Nome',
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
                                  color: Colors.blueGrey, width: 2.0)),
                          border: OutlineInputBorder(borderSide: BorderSide()),
                          labelStyle: TextStyle(fontStyle: FontStyle.italic),
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(Icons.phone_outlined),
                          labelText: 'Contato',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira um contato válido!';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        controller: password,
                        obscureText: passwordVisible,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            labelStyle: TextStyle(fontStyle: FontStyle.italic),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.password_outlined),
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
                                })),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira uma senha válida!';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        controller: confirm,
                        obscureText: passwordVisible,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                                OutlineInputBorder(borderSide: BorderSide()),
                            labelStyle: TextStyle(fontStyle: FontStyle.italic),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.password_outlined),
                            labelText: 'Confirmar Senha',
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
                                })),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira uma confirmação válida!';
                          }
                          if (confirm.text != password.text) {
                            return 'Senha e confirmação não coincidem!!';
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
            top: 530,
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
                      if (_formKey.currentState!.validate()) signUp();
                    },
                  )),
            ),
          ),
          Positioned(
            top: 570,
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
    else return Scaffold(
      body: Stack(
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
            top: 300,
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
                        controller: email,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueGrey, width: 2.0)),
                          border: OutlineInputBorder(borderSide: BorderSide()),
                          labelStyle: TextStyle(fontStyle: FontStyle.italic),
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira um e-mail válido!';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: name,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueGrey, width: 2.0)),
                          border: OutlineInputBorder(borderSide: BorderSide()),
                          labelStyle: TextStyle(fontStyle: FontStyle.italic),
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(Icons.person_2_outlined),
                          labelText: 'Nome',
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
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                          // for version 2 and greater youcan also use this
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueGrey, width: 2.0)),
                          border: OutlineInputBorder(borderSide: BorderSide()),
                          labelStyle: TextStyle(fontStyle: FontStyle.italic),
                          fillColor: Colors.white,
                          filled: true,
                          prefixIcon: Icon(Icons.phone_outlined),
                          labelText: 'Contato',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira um contato válido!';
                          }
                          return null;
                        },
                      ),
                     SizedBox(height: 20.0),
                      TextFormField(
                        controller: password,
                        obscureText: passwordVisible,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                            OutlineInputBorder(borderSide: BorderSide()),
                            labelStyle: TextStyle(fontStyle: FontStyle.italic),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.password_outlined),
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
                                })),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira uma senha válida!';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: confirm,
                        obscureText: passwordVisible,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueGrey, width: 2.0)),
                            border:
                            OutlineInputBorder(borderSide: BorderSide()),
                            labelStyle: TextStyle(fontStyle: FontStyle.italic),
                            fillColor: Colors.white,
                            filled: true,
                            prefixIcon: Icon(Icons.password_outlined),
                            labelText: 'Confirmar Senha',
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
                                })),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira uma confirmação válida!';
                          }
                          if (confirm.text != password.text) {
                            return 'Senha e confirmação não coincidem!!';
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
            top: 650,
            child: Container(
              width: 600,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    color: Colors.lightBlue,
                    child: Text(
                      "Registar",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) signUp();
                    },
                  )),
            ),
          ),
          Positioned(
            top: 700,
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
          Positioned(
            top: 750,
            child: Container(
              width: 600,
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
