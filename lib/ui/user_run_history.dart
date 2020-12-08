import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:safety_tracker_app/models/models.dart';
import 'package:safety_tracker_app/services/auth_service.dart';
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
        title: Text("My Run History"),
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
  final List<Run> myRuns = <Run>[
    new Run(distance: 20.34, startTime: new DateTime.utc(1997, 12, 21), endTime: new DateTime.utc(1997, 12, 20), userId: AuthenticationService(FirebaseAuth.instance).getCurrentUser().uid),
    new Run(distance: 22.34, startTime: new DateTime.utc(2001, 12, 21), endTime: new DateTime.utc(2001, 12, 23), userId: AuthenticationService(FirebaseAuth.instance).getCurrentUser().uid),
    new Run(distance: 10.14, startTime: new DateTime.utc(1998, 12, 21), endTime: new DateTime.utc(1998, 12, 21), userId: AuthenticationService(FirebaseAuth.instance).getCurrentUser().uid),
    new Run(distance: 18.34, startTime: new DateTime.utc(2010, 12, 21), endTime: new DateTime.utc(2010, 12, 23), userId: AuthenticationService(FirebaseAuth.instance).getCurrentUser().uid),
    new Run(distance: 20.34, startTime: new DateTime.utc(2019, 12, 21), endTime: new DateTime.utc(2019, 12, 22), userId: AuthenticationService(FirebaseAuth.instance).getCurrentUser().uid),
  ];
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: myRuns.length,
      itemBuilder: (BuildContext context, int index){
        return ListTile(
          leading: Icon(Icons.run_circle_outlined),
          title: Text('${myRuns[index].distance} km'),
          subtitle: Text("From ${ convertDateToString(myRuns[index].startTime)}" + " to ${ convertDateToString(myRuns[index].endTime)}"),
        );
      },
    );
  }

}
