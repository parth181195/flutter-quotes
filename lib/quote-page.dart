import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quotes/api.dart';
import 'dart:async';

import 'package:quotes/login.dart';

class QuotesHome extends StatefulWidget {
  @override
  _QuotesHomeState createState() => new _QuotesHomeState();
}

class _QuotesHomeState extends State<QuotesHome> {
  PageController pageViewController;
  PageStorage page;
  StreamSubscription<QuerySnapshot> usersubscription;
  StreamSubscription<QuerySnapshot> dataSubscription;
  CollectionReference userDataRef = Firestore.instance.collection('users');
  CollectionReference quotesRef = Firestore.instance.collection('quotes');
  List<DocumentSnapshot> quotes;
  DocumentSnapshot userData;
  List<dynamic> bookmarks = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dataSubscription = quotesRef.snapshots().listen((doc) {
      setState(() {
        quotes = doc.documents;
        pageViewController = new PageController(initialPage: quotes.length - 1);
      });
    });
    Fbapi.getUser().then((user) {
      usersubscription = userDataRef
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .snapshots()
          .listen((doc) {
        print(doc.documents[0].data);
        setState(() {
          userData = doc.documents[0];
          bookmarks = doc.documents[0].data['bookmarks'];
          bookmarks.add('value');
          print(bookmarks);
        });
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    dataSubscription?.cancel();
    usersubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: new Drawer(
          child: Text('data'),
        ),
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          actions: <Widget>[
            new IconButton(
              icon: Icon(
                Icons.exit_to_app,
                color: Colors.black,
              ),
              onPressed: () async {
                bool isloggedOut = await Fbapi.logOut();
                print(isloggedOut);
                if (isloggedOut) {
                  Navigator.of(context)
                      .pushReplacement(new MaterialPageRoute(
                          builder: (context) => new LoginPage()))
                      .then((data) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Signed Out'),
                    ));
                  });
                }
              },
            )
          ],
          elevation: 0.0,
          title: Text('Quotes',
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontFamily: 'Playfair Display',
                  color: Colors.black,
                  height: 0.5,
                  fontSize: 30.0)),
          centerTitle: true,
        ),
        body: SizedBox.expand(
          child: new Container(
            // padding:
            color: Colors.white,
            child: quotes != null
                ? PageView.builder(
                    controller: pageViewController,
                    itemCount: quotes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(12.0),
                        child:
                            new Stack(fit: StackFit.expand, children: <Widget>[
                          Align(
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Text(quotes[index].data['text'],
                                      style: new TextStyle(
                                          fontFamily: 'Playfair Display',
                                          fontSize: 40.0)),
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                  ),
                                  Text(
                                      quotes[index].data.containsKey('author')
                                          ? quotes[index].data['author']
                                          : 'A wise Person',
                                      style: new TextStyle(
                                          fontFamily: 'Playfair Display',
                                          color: Color(0xffaaaaaa),
                                          fontSize: 20.0)),
                                  Padding(
                                    padding: EdgeInsets.all(30.0),
                                  ),
                                ],
                              )),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  new IconButton(
                                    icon: Icon(
                                      bookmarks.contains(
                                              quotes[index].documentID)
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: Colors.black,
                                    ),
                                    onPressed: () async {
                                      print(bookmarks
                                          .contains(quotes[index].documentID));
                                      Map data = userData.data;
                                      bool addedBookmark = !bookmarks
                                          .contains(quotes[index].documentID);
                                      if (bookmarks
                                          .contains(quotes[index].documentID))
                                        data['bookmarks'] = new List.from(
                                            bookmarks)
                                          ..remove(quotes[index].documentID);
                                      else
                                        data['bookmarks'] =
                                            new List.from(bookmarks)
                                              ..add(quotes[index].documentID);
                                      userData.reference
                                          .updateData(data)
                                          .whenComplete(() {
                                        print('bokkmark added');
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(addedBookmark
                                              ? 'Quote added to bookmarks'
                                              : 'Quote removed from bookmarks'),
                                          duration: new Duration(seconds: 2),
                                        ));
                                        setState(() {});
                                      });
                                      // if (bookmarks
                                      //     .contains(quotes[index].documentID)) {
                                      //       data['bookmarks'] = bookmarks.remove(quotes[index].documentID);
                                      // } else {
                                      //   data['bookmarks'] =
                                      //       new List.from(bookmarks)
                                      //         ..add(quotes[index].documentID);
                                      // }
                                    },
                                  )
                                ]),
                          )
                        ]),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation(Colors.black),
                          strokeWidth: 1.0,
                        )
                      ],
                    ),
                  ),
          ),
        ));
  }
}

// child: new Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.stretch,
//                           children: <Widget>[
//                             Text(quotes[index].data['text'],
//                                 style: new TextStyle(
//                                     fontFamily: 'Playfair Display',
//                                     fontSize: 40.0)),
//                             Padding(
//                               padding: EdgeInsets.all(10.0),
//                             ),
//                             Text(
//                                 quotes[index].data.containsKey('author')
//                                     ? quotes[index].data['author']
//                                     : 'A wise Person',
//                                 style: new TextStyle(
//                                     fontFamily: 'Playfair Display',
//                                     color: Color(0xffaaaaaa),
//                                     fontSize: 20.0)),
//                             Padding(
//                               padding: EdgeInsets.all(60.0),
//                             ),
//                             new Positioned(
//                               bottom: 0.0,
//                               child: Text('part'),
//                             )
//                           ],
//                         ),
