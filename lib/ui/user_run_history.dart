import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:safety_tracker_app/utils/utils.dart';

class UserRunHistory extends StatefulWidget {
  @override
  _UserRunHistoryState createState() => _UserRunHistoryState();
}

class _UserRunHistoryState extends State<UserRunHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Run History",),
      ),
      body: MyRunsList(),
    );
  }
}

class MyRunsList extends StatefulWidget{
  @override
  _MyRunsList createState() =>
    _MyRunsList();
}

class _MyRunsList extends State<MyRunsList>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("runs")
        .where("userId", isEqualTo: FirebaseAuth.instance.currentUser.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError)
            return Text('Error: ${snapshot.error}');
          if(snapshot.hasData){
            return new ListView(
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                if(document.exists){
                  return new ListTile(
                    leading: Icon(Icons.run_circle_outlined, color: Constants.appThemeColor, size: 42,),
                    title: new Text("${document['distance']} km", style: TextStyle(color: Constants.appThemeColor, fontSize: 24),),
                    subtitle: new Text(convertTimestampToString(document['startTime']) + " - " + convertTimestampToString(document['endTime']),
                      style: TextStyle(color: Constants.appThemeColor, fontSize: 17),),
                  );
                }
                return Text("No run yet!", style: TextStyle(color: Constants.appThemeColor, fontSize: 17));
              }).toList(),
            );
          }else{
            return Text("No run yet!",  style: TextStyle(color: Constants.appThemeColor, fontSize: 17));
          }
        },
      ),
    );
  }

}
