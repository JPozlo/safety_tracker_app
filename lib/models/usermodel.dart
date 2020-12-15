import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safety_tracker_app/utils/functions.dart';

class UserData {
  final String uid;
  final String displayName;
  final String email;
  final String phoneNumber;
  final DateTime creationDate;
  final String groupId;
  final String avatar;
  final int treks;
  final String deviceToken;

  const UserData({
    this.uid,
    this.displayName,
    this.email,
    this.phoneNumber,
    this.creationDate,
    this.groupId,
    this.treks,
    this.avatar,
    this.deviceToken
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
        uid: json['uid'].toString(),
        displayName: json['displayName'].toString(),
        email: json['email'].toString(),
        phoneNumber: json['phoneNumber'].toString(),
        creationDate: json['creationDate'] as DateTime,
        groupId: json['groupId'].toString(),
        deviceToken: json['deviceToken'].toString(),
        avatar: json['photoURL]'].toString(),
        treks: json['treks'] as int);
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'photoURL': avatar,
    'treks': treks,
    'displayName': displayName,
    'groupId': groupId,
    'creationDate': creationDate,
    'email': email,
    'deviceToken': deviceToken,
    'phoneNumber': phoneNumber
  };

  // Transforms the query result into a list of UserData
  List<UserData> toUsers(QuerySnapshot query) => query.docs
      .map((e) => UserData.fromDocument(e))
      .where((element) => element != null)
      .toList();

  // Transforms a single document into a single UserData
  factory UserData.fromDocument(DocumentSnapshot document) => document.exists
      ? UserData(
          uid: document.data()['uid'],
          displayName: document.data()['displayName'],
          email: document.data()['email'],
          phoneNumber: document.data()['phoneNumber'],
          creationDate: convertTimestampToDatetime(document.data()['creationDate'] ?? 0),
          groupId: document.data()['groupId'] ?? null,
          treks: document.data()['treks'],
          deviceToken: document.data()['deviceToken'],
          avatar: document.data()['photoURL'])
      : null;


}
