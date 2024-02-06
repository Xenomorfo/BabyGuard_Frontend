import 'package:flutter/material.dart';
import 'package:myapp/pages/signup.dart';
import 'package:myapp/pages/renew_password.dart';
import 'package:myapp/pages/dashboard.dart';
import 'package:myapp/pages/new_password.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:uni_links/uni_links.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription? _sub;
  bool passwordVisible=true;
  final _formKey = GlobalKey<FormState>();

  Future<void> initUniLinks() async {
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        debugPrint('listener is working');
        var uri = Uri.parse(link);
        if (uri.queryParameters['token'] != null) {
          debugPrint(uri.queryParameters['token'].toString());

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  NovaPassword(user: uri.queryParameters['id']),
            ),
          );
        }
      }
    }, onError: (err) {});
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();

  }

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future login() async {
    var url = "http://192.168.1.5:3000/authenticate";
    Map data = {"email": email.text, "password": password.text};

    // Encode Map to JSON
    var body = json.encode(data);

    var response = await http.post(Uri.parse(url),
        headers: {"Content-Type": "application/json"}, body: body);

    var userData = json.decode(response.body);
    debugPrint(userData["chairId"]);
    if (userData['msg'] == 'User not found') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
    }else if(userData['msg'] == 'Wrong password'){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Erro"),
        content: Text("Senha Errada!"),
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
          builder: (context) => Dashboard(
              user: userData,
              /*id: userData["id"],
              name: userData["name"],
              email: userData["email"],
              contact: userData["contact"],
              serial: userData["serial"],
              password: userData["password"],
              token: userData["token"]*/)
        ),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Olá " + userData['name'] ),
          content: Text("Autênticação bem-sucedida"),
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
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(

          appBar: AppBar(

            title: new Center(child: Text('Baby Guard')),
            backgroundColor: Colors.grey[100],
            foregroundColor: Colors.blue[900],
            automaticallyImplyLeading: false, // Nao permite voltar atras
          ),
          body: Stack(
            children: [
              Container(
                //color: Colors.grey[100],
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(width: 1.0, color: Colors.black),
                    right: BorderSide(width: 1.0, color: Colors.black),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                    child:  CircleAvatar(
                      backgroundImage: AssetImage("images/bebe_auto_clip.jpg"),
                      radius:100,
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
                      child: Column (
                      children:<Widget> [
                        TextFormField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira um e-mail válido!';
                          }
                          return null;
                        },

                      ),
                        TextFormField(
                          obscureText: passwordVisible,
                          controller: password,
                          decoration: InputDecoration(
                            labelText: 'Password',
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
                              },

                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Insira uma senha válida!';
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
                top: 360,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        color: Colors.lightBlue,
                        child: Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if(_formKey.currentState!.validate()) login();
                        },
                      )),
                ),
              ),
              Positioned(
                top: 400,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      child: Text(
                        "Repor Senha",
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        //debugPrint("signup");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReporPassword()),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 440,
                child: Container(
                  width: MediaQuery.of(context).size.width,

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      child: Text(
                        "Registar-se",
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () {
                        //debugPrint("signup");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Signup()),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          )
      )
    );
  }
}
