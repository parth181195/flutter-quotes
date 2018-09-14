import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share/share.dart';
import 'package:quotes/api.dart';

class QuotesHome extends StatefulWidget {
  _QuotesHomeState createState() => _QuotesHomeState();
}

class _QuotesHomeState extends State<QuotesHome> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: <Widget>[
          new IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.black,
            ),
            onPressed: () async {
              await Fbapi.logOut().catchError((e) => print(e));
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
      body: QuotesWidget(),
    );
  }
}

class QuotesWidget extends StatefulWidget {
  @override
  _QuotesWidgetState createState() => new _QuotesWidgetState();
}

class _QuotesWidgetState extends State<QuotesWidget> {
  PageController pageViewController;
  PageStorage page;
  StreamSubscription<QuerySnapshot> usersubscription;
  StreamSubscription<QuerySnapshot> dataSubscription;
  CollectionReference userDataRef = Firestore.instance.collection('users');
  CollectionReference quotesRef = Firestore.instance.collection('quotes');
  List<DocumentSnapshot> quotes;
  DocumentSnapshot userData;
  List<dynamic> bookmarks = [];
  GlobalKey _globalKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
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
          print(bookmarks);
        });
      });
    });
    dataSubscription = quotesRef.snapshots().listen((doc) {
      setState(() {
        quotes = doc.documents;
        pageViewController = new PageController(
            initialPage: new Random().nextInt(quotes.length));
      });
    });
  }

  Future<String> get _localPath async {
    final directory = await getExternalStorageDirectory();
    Directory quoteFolder = Directory('${directory.path}');
    if (!quoteFolder.existsSync()) {
      quoteFolder.createSync();
    }
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/share.png');
  }

  Future<File> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      // RenderRepaintBoundary boundary =
      //     globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      debugPrint(base64Encode(pngBytes));
      final file = await _localFile;
      file.writeAsBytesSync(pngBytes);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Image Stored at ${file.path}'),
        action: SnackBarAction(
          label: 'open image',
          onPressed: () {
            OpenFile.open(file.path).catchError((e) => print(e));
          },
        ),
      ));
      setState(() {});
      return file;
    } catch (e) {
      print(e);
    }
  }

  String getAuthor(index) {
    return quotes[index].data.containsKey('author')
        ? quotes[index].data['author']
        : 'A wise Person';
  }

  Widget getBookmarkbar(index) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        new IconButton(
          icon: Icon(
            Icons.file_download,
            color: Colors.black,
          ),
          onPressed: _capturePng,
        ),
        new IconButton(
          icon: Icon(
            bookmarks.contains(quotes[index].documentID)
                ? Icons.bookmark
                : Icons.bookmark_border,
            color: Colors.black,
          ),
          onPressed: () async {
            print(bookmarks.contains(quotes[index].documentID));
            Map data = userData.data;
            if (bookmarks.contains(quotes[index].documentID))
              data['bookmarks'] = new List.from(bookmarks)
                ..remove(quotes[index].documentID);
            else
              data['bookmarks'] = new List.from(bookmarks)
                ..add(quotes[index].documentID);
            setState(() {
              bookmarks = data['bookmarks'];
            });
            userData.reference.updateData(data).whenComplete(() {
              print('bokkmark added');
            });
          },
        ),
        new IconButton(
          icon: Icon(
            Icons.share,
            color: Colors.black,
          ),
          onPressed: () {
            Share.share(quotes[index].data['text'] + '\n-' + getAuthor(index));
          },
        )
      ]),
    );
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
    return SizedBox.expand(
      child: new Container(
        // padding:
        color: Colors.white,
        child: quotes != null
            ? RepaintBoundary(
                key: _globalKey,
                child: PageView.builder(
                  physics: BouncingScrollPhysics(),
                  controller: pageViewController,
                  itemCount: quotes.length,
                  itemBuilder: (context, index) {
                    return new Stack(fit: StackFit.expand, children: <Widget>[
                      Quotetext(
                        text: quotes[index].data['text'],
                        author: getAuthor(index),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: getBookmarkbar(index),
                      )
                    ]);
                  },
                ))
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
    );
  }
}

class Quotetext extends StatelessWidget {
  final String text;
  final String author;
  Quotetext({this.text, this.author});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      color: Colors.white,
      child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(text,
                  style: new TextStyle(
                      fontFamily: 'Playfair Display', fontSize: 40.0)),
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              Text(author,
                  style: new TextStyle(
                      fontFamily: 'Playfair Display',
                      color: Color(0xffaaaaaa),
                      fontSize: 20.0)),
              Padding(
                padding: EdgeInsets.all(30.0),
              ),
            ],
          )),
    );
  }
}
