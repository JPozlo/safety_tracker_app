import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Stream<QuerySnapshot> getUsersOfGroup({String groupId}) {
    return _firestore
        .collection("users")
        .where("groupId", isEqualTo: groupId)
        .snapshots();
  }

  String getAndSetToken() {
    var myToken = "";
    _firebaseMessaging.getToken().then((token) {
      print("Device Token: $token");
      myToken = token;
      _firestore.collection("users").doc(FirebaseAuth.instance.currentUser.uid).set({"deviceToken": token}, SetOptions(merge: true)).then((value) => {
        print("Successfully saved the token!")
      }).catchError((err) => {
        myToken = "",
        print("Error in saving token: $err")
      });
    }).catchError((err) => {
      myToken = "",
      print("Error in getting token: $err")
    });
    return myToken;
  }

  updateUserName(String displayName) async {
    return await _firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({"displayName": displayName}, SetOptions(merge: true));
  }

  updateUserEmail(String email) async {
    return await _firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({"email": email}, SetOptions(merge: true));
  }

  updateUserPhoto(String imagePath) async {
    return await _firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({"photoURL": imagePath}, SetOptions(merge: true));
  }
}
