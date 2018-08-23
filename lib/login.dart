import 'package:flutter/material.dart';
import 'package:quotes/api.dart';
import 'dart:async';

import 'package:quotes/quote-page.dart';

class LoginPage extends StatelessWidget {
  Future<bool> _loginUser() async {
    final api = await Fbapi.signInWithGoogle();
    if (api != null) {
      return true;
    } else {
      return false;
    }
  }

  presentSnackbar(context) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Signed Out')));
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
            new Container(
                padding: EdgeInsets.only(bottom: 30.0),
                child: new SizedBox(
                  width: 150.0,
                  height: 50.0,
                  child: new Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25.0),
                    child: InkWell(
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
                        bool b = await _loginUser();
                        b
                            ? Navigator.of(context).pushReplacement(
                                new MaterialPageRoute(
                                    builder: (context) => new QuotesHome()))
                            : Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('worng Email'),
                              ));
                      },
                    ),
                  ),
                ))
          ],
        ),
      ),
    ));
  }
}
