import 'package:flutter/material.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/main_pages/login.dart';
import 'dart:convert';

class NovaPassword extends StatefulWidget {
  final user;
  final Widget? sidebar;

  const NovaPassword({super.key, required this.user, this.sidebar});

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
    Map data = {"id": widget.user['id'], "password": password.text};
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
    if (MediaQuery.of(context).size.width < 640)
      return Scaffold(
          appBar: AppBar(
            title: Text('Nova Senha'),
          ),
          body: Stack(alignment: Alignment.center, children: [
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
                          obscureText: passwordVisible,
                          enableSuggestions: false,
                          autocorrect: false,
                          controller: password,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 2.0)),
                              border:
                                  OutlineInputBorder(borderSide: BorderSide()),
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.password_outlined),
                              labelStyle:
                                  TextStyle(fontStyle: FontStyle.italic),
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
                        SizedBox(height: 15.0),
                        TextFormField(
                          obscureText: confirmPasswordVisible,
                          enableSuggestions: false,
                          autocorrect: false,
                          controller: conf_password,
                          decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.blueGrey, width: 2.0)),
                              border:
                                  OutlineInputBorder(borderSide: BorderSide()),
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                              fillColor: Colors.white,
                              filled: true,
                              prefixIcon: Icon(Icons.password_outlined),
                              labelStyle:
                                  TextStyle(fontStyle: FontStyle.italic),
                              labelText: 'Confirmar Senha',
                              suffixIcon: IconButton(
                                  icon: Icon(confirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  onPressed: () {
                                    setState(
                                      () {
                                        confirmPasswordVisible =
                                            !confirmPasswordVisible;
                                      },
                                    );
                                  })),
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
                        if (_formKey.currentState!.validate())
                          verifica_password();
                      },
                    )),
              ),
            ),

          ]));
    else
      return Scaffold(
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
                    .containing(Stack(alignment: Alignment.center, children: [
                  Positioned(
                    top: 50,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: CircleAvatar(
                        backgroundImage:
                            AssetImage("images/bebe_auto_clip.jpg"),
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
                                obscureText: passwordVisible,
                                enableSuggestions: false,
                                autocorrect: false,
                                controller: password,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                            width: 2.0)),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide()),
                                    hintStyle:
                                        TextStyle(fontStyle: FontStyle.italic),
                                    fillColor: Colors.white,
                                    filled: true,
                                    prefixIcon: Icon(Icons.password_outlined),
                                    labelStyle:
                                        TextStyle(fontStyle: FontStyle.italic),
                                    labelText: 'Senha',
                                    suffixIcon: IconButton(
                                        icon: Icon(passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                        onPressed: () {
                                          setState(
                                            () {
                                              passwordVisible =
                                                  !passwordVisible;
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
                              SizedBox(height: 50.0),
                              TextFormField(
                                obscureText: confirmPasswordVisible,
                                enableSuggestions: false,
                                autocorrect: false,
                                controller: conf_password,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                            width: 2.0)),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide()),
                                    hintStyle:
                                        TextStyle(fontStyle: FontStyle.italic),
                                    fillColor: Colors.white,
                                    filled: true,
                                    prefixIcon: Icon(Icons.password_outlined),
                                    labelStyle:
                                        TextStyle(fontStyle: FontStyle.italic),
                                    labelText: 'Confirmar Senha',
                                    suffixIcon: IconButton(
                                        icon: Icon(confirmPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                        onPressed: () {
                                          setState(
                                            () {
                                              confirmPasswordVisible =
                                                  !confirmPasswordVisible;
                                            },
                                          );
                                        })),
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
                              if (_formKey.currentState!.validate())
                                verifica_password();
                            },
                          )),
                    ),
                  ),
                ])),
                gridArea('h').containing(
                  Container(
                      color: Colors.black,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Text("Nova Senha",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)),
                            )
                          ])),
                )
              ]));
  }
}
