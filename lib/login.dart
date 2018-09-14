import 'package:flutter/material.dart';
import 'package:quotes/api.dart';
import 'dart:async';

enum AuthStatus {
  loggedin,
  notLoggedin,
  notDetermined,
}

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() {
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  StreamSubscription userLoginSubscription;

  Future<bool> _loginUser() async {
    final api = await Fbapi.signInWithGoogle();
    if (api) {
      return true;
    } else {
      return false;
    }
  }

  AuthStatus authStatus = AuthStatus.notLoggedin;
  @override
  void initState() {
    super.initState();
    userLoginSubscription = Fbapi.auth.onAuthStateChanged.listen((val) {
      this.setState(() {
        authStatus = val != null ? AuthStatus.loggedin : AuthStatus.notLoggedin;
      });
    });
  }

  Widget buildWidgets() {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return buildLoader();
        break;
      case AuthStatus.loggedin:
        return buildLoader();
        break;
      case AuthStatus.notLoggedin:
        return buildLoginBtn();
        break;
      default:
    }
  }

  Widget buildLoader() {
   return Container(
          padding: EdgeInsets.only(bottom: 30.0),
          child: new CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 1.0,
          ),
        );
  }

  Widget buildLoginBtn() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30.0),
      child: SizedBox(
        height: 50.0,
        width: 150.0,
        child: new Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(25.0),
            child: Stack(
              fit: StackFit.expand,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: new Image.asset('assets/images/glogo.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text('Login',
                        // textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 25.0,
                            height: 0.5)),
                  ),
                ),
              ],
            ),
            onTap: () async {
              setState(() {
                authStatus = AuthStatus.notDetermined;
              });
              await _loginUser().then((val) {
                if (mounted) {
                  setState(() {
                    authStatus =
                        val ? AuthStatus.loggedin : AuthStatus.notLoggedin;
                  });
                }
              }).catchError((e) {
                print(e);
                if (mounted) {
                  setState(() {
                    authStatus = AuthStatus.notLoggedin;
                  });
                }
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    userLoginSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox.expand(
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        color: Colors.black,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: <Widget>[
                Text('Quotes',
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontFamily: 'Playfair Display',
                        color: Colors.white,
                        fontSize: 75.0)),
                Text('Stay Motivated',
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                        fontFamily: 'Playfair Display',
                        color: Colors.white,
                        fontSize: 30.0)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: new Image.asset('assets/images/loginbg.png'),
            ),
            buildWidgets()
          ],
        ),
      ),
    ));
  }
}
