import 'package:safety_tracker_app/models/models.dart';

class Group{
  final String groupName;
  final DateTime createdAt;

  const Group({
    this.groupName,
    this.createdAt
});

  factory Group.fromJson(Map<String, dynamic> json){
    return Group(
      groupName: json['name'],
      createdAt: json['createdAt'],
    );
  }
}