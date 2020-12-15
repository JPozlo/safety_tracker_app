import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class GroupService {
  final _firestore = FirebaseFirestore.instance;

  addGroup({String name}) {
    var docId = _firestore.collection("groups").doc().id;
    _firestore
        .collection("groups")
        .doc(docId)
        .set({"groupId": docId, "groupName": name, "createdAt": DateTime.now()},
            SetOptions(merge: true))
        .then((_) => {
              _firestore
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .set({'groupId': docId}, SetOptions(merge: true))
                  .then((value) => {
                    addStringToPrefs(Constants.groupID, docId),
                    print("Success")
                  })
                  .catchError((e) => {print("Error due to: $e")})
            })
        .catchError((e) => {print("Error due to: $e")});
  }

  void getGroups() {
    _firestore
        .collection("groups")
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      snapshot.docs.forEach(
        (DocumentSnapshot documentSnapshot) {
          // prints all the documents available
          // in the collection
          debugPrint(documentSnapshot.data.toString());
        },
      );
    });
  }

  void getGroup(String docID) {
    _firestore
        .collection("groups")
        .doc(docID)
        .get()
        .then((DocumentSnapshot snapshot) {
      // prints the document Map{}
      debugPrint(snapshot.data.toString());
    });
  }

  String getGroupId() {
    var mySTring = "";
    _firestore
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((val) {
      if (val.exists) {
        mySTring = val.data()['groupId'];
        print("The value of mySTring: ${val.data()['groupId']}");
      } else {
        print("Not found");
        mySTring = "";
      }
    }).catchError((e) => {print("Error getting group Id: $e")});
    return mySTring;
  }

  Future<QuerySnapshot> getGroupMembers({String groupId}) async {
    return await _firestore
        .collection("users")
        .where("groupId", isEqualTo: groupId)
        .get();
  }

  getAllUsers() async {
    return await _firestore.collection("users").get();
  }

  saveRun(
      {String groupId,
      double distance,
      DateTime startTime,
      DateTime endTime}) async {
    var docId = _firestore.collection("runs").doc().id;
    return await _firestore.collection("runs").doc(docId).set({
      "groupId": groupId,
      "runId": docId,
      "userId": FirebaseAuth.instance.currentUser.uid,
      "username": FirebaseAuth.instance.currentUser.displayName,
      "distance": distance,
      "startTime": startTime,
      "endTime": endTime
    }, SetOptions(merge: true));
  }


  saveInitialRun({String groupId}) async {
    var docId = _firestore.collection("startRun").doc().id;
    return await _firestore.collection("startRun").doc(docId).set({
      "groupId": groupId,
      "username": FirebaseAuth.instance.currentUser.displayName,
      "startRunId": docId,
      "userId": FirebaseAuth.instance.currentUser.uid
    }, SetOptions(merge: true));
}

  addMember({String groupId, String userId}) async {
    return await _firestore
        .collection("users")
        .doc(userId)
        .set({"groupId": groupId}, SetOptions(merge: true));
  }
}
