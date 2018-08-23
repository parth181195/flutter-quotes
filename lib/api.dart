import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Fbapi {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn _gSignin = GoogleSignIn();
  static CollectionReference colRef = Firestore.instance.collection('users');
  FirebaseUser firebaseUser;
  Fbapi(FirebaseUser user) {
    firebaseUser = user;
  }
  static Future<Fbapi> signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _gSignin.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final FirebaseUser user = await _auth.signInWithGoogle(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    assert(user.email != null);
    assert(user.displayName != null);
    assert(await user.getIdToken() != null);
    final FirebaseUser currentUser = await _auth.currentUser();
    colRef
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .getDocuments()
        .then((doc) {
      print(doc.documents.isEmpty);
      if (doc.documents.isEmpty) {
        Firestore.instance.runTransaction((Transaction transaction) async {
          CollectionReference reference =
              Firestore.instance.collection('users');

          await reference.add({'uid': user.uid, 'bookmarks': []});
        });

        // colRef.document().a({'uid':user.uid,'bookmarks':[]});
        print('user created');
      } else {
        print('user exists');
      }
      // print();
    });
    assert(user.uid == currentUser.uid);
    return Fbapi(user);
  }

  static Future<bool> logOut() async {
    bool a = await _auth.signOut().then((bool) {return true;});
    bool b = await _gSignin.signOut().then((bool) { return true;});
    return a && b;
  }

  static Future<bool> isLoggedIn() async {
    final FirebaseUser user = await _auth.currentUser();
    return user.uid != null ? true : false;
  }

  static Future<FirebaseUser> getUser() async {
    final FirebaseUser user = await _auth.currentUser();
    return user;
  }
}
