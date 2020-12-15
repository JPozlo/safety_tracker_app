import 'package:cloud_firestore/cloud_firestore.dart';

class Run{
  final String runId;
  final double distance;
  final DateTime startTime;
  final DateTime endTime;
  final String userId;
  final String username;
  final String groupId;

 const Run({this.runId, this.distance, this.startTime, this.endTime, this.userId, this.groupId, this.username});

  factory Run.fromJson(Map<String, dynamic> json){
    return Run(
      runId: json['runId'],
      distance: json['distance'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      userId: json['userId'],
      username: json['username'],
      groupId: json['groupId']
    );
  }

  Map<String, dynamic> toJson() => {
    'runId': runId,
    'distance': distance,
    'startTime': startTime,
    'endTime': endTime,
    'userId': userId,
    'username': username,
    'groupId': groupId,
  };

  factory Run.fromDocument(DocumentSnapshot document) {
    return Run(
        runId: document['runId'],
        distance: document['distance'],
        startTime: document['startTime'],
        endTime: document['endTime'],
        userId: document['userId'],
        username: document['username'],
        groupId: document['groupId']);
  }
}