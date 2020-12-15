import 'package:cloud_firestore/cloud_firestore.dart';

class Group{
  final String groupId;
  final String groupName;
  final DateTime createdAt;

  const Group({
    this.groupId,
    this.groupName,
    this.createdAt
});

  factory Group.fromJson(Map<String, dynamic> json){
    return Group(
      groupId: json['groupId'],
      groupName: json['groupName'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'groupId': groupId,
    'name': groupName,
    'createdAt': createdAt,
  };

  factory Group.fromDocument(DocumentSnapshot document) {
    return Group(
        groupId: document['groupId'],
        groupName: document['groupName'],
        createdAt: document['createdAt']
    );
  }
}