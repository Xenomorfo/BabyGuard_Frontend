import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/main_pages/edit_profile.dart';
import 'package:myapp/main_pages/signup.dart';
import 'package:myapp/main_pages/renew_password.dart';
import 'package:myapp/main_pages/dashboard.dart';
import 'package:myapp/main_pages/dash_web.dart';
import 'package:myapp/main_pages/new_password.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);

  }

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future login() async {

    var url = "http://xenomorfo.ddns.net:3000/authenticate";
    Map data = {"email": email.text, "password": password.text};

    // Encode Map to JSON
    var body = json.encode(data);
    var response;
    try {
      response = await http.post(Uri.parse(url),
          headers: {"Content-Type": "application/json"}, body: body);
    } catch(error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Erro"),
          content: Text("Servidor fora de serviço!"),
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
      throw Exception();
    }
    var userData = json.decode(response.body);

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
      if(MediaQuery.of(context).size.width < 640)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => userData['serial'].toString().length == 10 ?
            Dashboard(user: userData) : Editprofile(user: userData)
        ),
      );
      else
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => userData['serial'].toString().length == 10 ?
              Dashweb(user: userData) : Editprofile(user: userData)
          ),
        );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Olá " + userData['name'] ),
          content: userData['serial'].toString().length == 10 ?
            Text("Autênticação bem-sucedida") : Text("Número de série da cadeira inválido."),
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
                top: 240,
                child: Container(
                  width: MediaQuery.of(context).size.width > 640 ? 600 :
                  MediaQuery.of(context).size.width,

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
                        MediaQuery.of(context).size.width > 640 ? SizedBox(height: 20.0) :
                        SizedBox(height: 8.0),
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
                top: 410,
                child: Container(
                  width: MediaQuery.of(context).size.width > 640 ? 600 :
                  MediaQuery.of(context).size.width,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MaterialButton(
                        color: Colors.lightBlue,
                        child: Text(
                          "Entrar",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          if(_formKey.currentState!.validate()) login();
                        },
                      )),
                ),
              ),
              Positioned(
                top: 450,
                child: Container(
                  width: MediaQuery.of(context).size.width > 640 ? 600 :
                  MediaQuery.of(context).size.width,
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
                top: 490,
                child: Container(
                  width: MediaQuery.of(context).size.width > 640 ? 600 :
                  MediaQuery.of(context).size.width,
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
