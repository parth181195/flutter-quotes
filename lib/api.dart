import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class Fbapi {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static GoogleSignIn _gSignin = GoogleSignIn();
  static CollectionReference colRef = Firestore.instance.collection('users');
  FirebaseUser firebaseUser;

  static Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _gSignin.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final FirebaseUser user = await auth.signInWithGoogle(
          idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
      assert(user.email != null);
      assert(user.displayName != null);
      assert(await user.getIdToken() != null);
      final FirebaseUser currentUser = await auth.currentUser();
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
      return user.uid == currentUser.uid;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> logOut() async {
    await auth.signOut();
    await _gSignin.signOut();
    return true;
  }

  static Future<bool> isLoggedIn() async {
    final FirebaseUser user = await auth.currentUser();
    if (user != null) {
      return user.uid != null ? true : false;
    } else {
      return false;
    }
  }

  static Future<FirebaseUser> getUser() async {
    final FirebaseUser user = await auth.currentUser();
    return user;
  }
}
