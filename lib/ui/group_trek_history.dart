import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/models/models.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class GroupTrekHistory extends StatefulWidget {
  @override
  _GroupTrekHistoryState createState() => _GroupTrekHistoryState();
}

class _GroupTrekHistoryState extends State<GroupTrekHistory> {
  final List<Run> membersTest = <Run>[
      new Run(userId: "20", distance: 20.7, startTime: DateTime.utc(2018, 11, 6, 22), endTime: DateTime.utc(2018, 11, 6, 23)),
      new Run(userId: "20", distance: 12, startTime: DateTime.utc(2018, 11, 9, 22), endTime: DateTime.utc(2018, 11, 9, 23)),
      new Run(userId: "20", distance: 11, startTime: DateTime.utc(2018, 11, 10, 22), endTime: DateTime.utc(2018, 11, 10, 23)),
      new Run(userId: "901", distance: 23.7, startTime: DateTime.utc(2018, 10, 6, 22), endTime: DateTime.utc(2018, 10, 6, 23)),
      new Run(userId: "901", distance: 23.7, startTime: DateTime.utc(2018, 10, 6, 22), endTime: DateTime.utc(2018, 10, 6, 23)),
  ] ;


  List<Widget> getMembers(){
    List<Widget> childs = [];
    List<Color> mycolors = [Colors.red, Colors.green, Colors.yellow];
    final _random = Random();
    for (var i=0;i<membersTest.length;i++){
      var randomColour = mycolors[_random.nextInt(mycolors.length)];
      var randomColour2 = mycolors[_random.nextInt(mycolors.length)];
      childs.add(new CurvedListItem(
        userId: membersTest[i].userId,
        startTime: membersTest[i].startTime,
        endTime: membersTest[i].endTime,
        distance: membersTest[i].distance,
        color: randomColour,
        nextColor: randomColour2
      ));
    }
    return childs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History for group members"),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: getMembers(),
      ),
    );
  }
}

class CurvedListItem extends StatelessWidget {
  const CurvedListItem({
    this.distance,
    this.userId,
    this.startTime,
    this.endTime,
    this.color,
    this.nextColor,
  });

  final double distance;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final Color nextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: nextColor,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(80.0),
          ),
        ),
        padding: const EdgeInsets.only(
          left: 32,
          top: 80.0,
          bottom: 50,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    "${convertDateToString(startTime)} - ${convertDateToString(endTime)}",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
              Text(
                userId,
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 2,
              ),
              Text(
                distance.toString() + " km",
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Row(            ),
            ]),
      ),
    );
  }
}
