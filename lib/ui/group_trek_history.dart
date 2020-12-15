import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class GroupTrekHistory extends StatefulWidget {

  @override
  _GroupTrekHistoryState createState() => _GroupTrekHistoryState();
}

class _GroupTrekHistoryState extends State<GroupTrekHistory> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History for group members",),
      ),
      body: new FutureBuilder(
          future: getStringPrefs(Constants.groupID),
          builder: (context, snapshot) {
            Widget child;
            if (snapshot.hasData) {
              child = StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("runs")
                      .where("groupId", isEqualTo: snapshot.data)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return new Text('Error: ${snapshot.error}');
                    if (snapshot.hasData) {
                      return ListView(
                        children:
                        snapshot.data.docs.map((DocumentSnapshot document) {
                          if (document.exists) {
                            return new ListTile(
                              isThreeLine: true,
                              leading: Icon(
                                Icons.run_circle_outlined,
                                color: Constants.appThemeColor,
                                size: 42,
                              ),
                              title: new Text(
                                "${document['username']}",
                                style: TextStyle(
                                    color: Constants.appThemeColor,
                                    fontSize: 24),
                              ),
                              subtitle: new Text("${document['distance']} km\n${convertTimestampToString(document['startTime'])} -  ${convertTimestampToString(document['endTime'])}",
                                style: TextStyle(
                                    color: Constants.appThemeColor,
                                    fontSize: 17),
                              ),
                            );
                          }
                          return Text("No run yet!", style: TextStyle(color: Constants.appThemeColor, fontSize: 17));
                        }).toList(),
                      );
                    } else {
                      return Text("No run yet!", style: TextStyle(color: Constants.appThemeColor, fontSize: 17));
                    }
                  });
              return child;
            } else {
              return Text("No data yet!", style: TextStyle(color: Constants.appThemeColor, fontSize: 17));
            }
          }),
    );
  }
}
