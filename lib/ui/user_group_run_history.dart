import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class UserGroupRunHistory extends StatefulWidget {
  final String username;
  final String uid;

  UserGroupRunHistory({this.uid, this.username});

  @override
  _UserGroupRunHistoryState createState() => _UserGroupRunHistoryState();
}

class _UserGroupRunHistoryState extends State<UserGroupRunHistory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${this.widget.username} Run History",),
      ),
      body: UserRunsList(uid: this.widget.uid,),
    );
  }

}

class UserRunsList extends StatefulWidget{
  final String uid;
  UserRunsList({this.uid});

  @override
  _UserRunsList createState() =>
      _UserRunsList();
}

class _UserRunsList extends State<UserRunsList>{
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("runs")
          .where("userId", isEqualTo: this.widget.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError)
          return new Text('Error: ${snapshot.error}');
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
              return new Scaffold(
                  body: Column(
                    children: [
                      Row(
                        children: [
                          Text("No run yet", style: TextStyle(color: Constants.appThemeColor, fontSize: 17))
                        ],
                      )
                    ],
                  )
              );
            }).toList(),
          );
        }else{
          return new Scaffold(
            body: Column(
              children: [
                Row(
                  children: [
                    Text("No run yet", style: TextStyle(color: Constants.appThemeColor, fontSize: 17))
                  ],
                )
              ],
            )
          );
        }
      },
    );
  }

}