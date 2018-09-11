import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:quotes/api.dart';
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
    return new MaterialApp(
      title: 'Flutter Demo',
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: MyBehavior(),
          child: child,
        );
      },
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

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.notLoggedin;
  StreamSubscription userLoginSubscription;

  FirebaseUser user;
  @override
  void initState() {
    super.initState();
    userLoginSubscription = Fbapi.auth.onAuthStateChanged.listen((val) {
      this.setState(() {
        authStatus = val != null ? AuthStatus.loggedin : AuthStatus.notLoggedin;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    userLoginSubscription?.cancel();
  }

  static logout() async {
    await Fbapi.logOut().catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return RootWidget(
      authStatus: authStatus == AuthStatus.loggedin ? true : false,
      child: authStatus == AuthStatus.loggedin ? QuotesHome() : LoginPage(),
    );
  }
}

class RootWidget extends InheritedWidget {
  final bool authStatus;
  final Widget child;
  RootWidget({Key key, this.child, this.authStatus})
      : super(key: key, child: child);

  static RootWidget of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(RootWidget) as RootWidget);
  }

  @override
  bool updateShouldNotify(RootWidget oldWidget) {
    return authStatus != oldWidget.authStatus;
  }
}
