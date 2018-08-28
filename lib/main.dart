import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:quotes/api.dart';
import 'dart:async';

import 'package:quotes/login.dart';
import 'package:quotes/quote-page.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
    .then((_) {
      runApp(new MyApp());
    });
}
// void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print(DateTime.now());
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new RootPage(),
    );
  }
}

enum AuthStatus {
  loggedin,
  notLoggedin,
  notDetermined,
}

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notLoggedin;
  @override
  void initState() {
    super.initState();
    Fbapi.isLoggedIn().then((val) {
      print(val);
      print(DateTime.now());
      setState(() {
        authStatus = val ? AuthStatus.loggedin : AuthStatus.notLoggedin;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
        return LoginPage();
  }


}
