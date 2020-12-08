import 'package:safety_tracker_app/models/models.dart';

class UserData {
  final String uid;
  final String displayName;
  final DateTime creationDate;
  final String groupId;
  final String avatar;
  final int treks;

  const UserData ({
    this.uid,
    this.displayName,
    this.creationDate,
    this.groupId,
    this.treks,
    this.avatar,
  });

  factory UserData.fromJson(Map<String, dynamic> json){
    return UserData(
      uid: json['uid'].toString(),
      displayName: json['displayName'].toString(),
      creationDate: json['creationDate'] as DateTime,
      groupId: json['groupId'].toString(),
      avatar: json['avatar'].toString(),
      treks: json['treks'] as int
    );
  }
}