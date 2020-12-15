import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class UserGroups extends StatefulWidget {
  final String theGroupId;

  UserGroups({Key key, @required this.theGroupId}) : super(key: key);

  @override
  _UserGroupsState createState() => _UserGroupsState();
}

class _UserGroupsState extends State<UserGroups> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Group",)),
      body: GroupMembers(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddNewMembers()));
        },
        child: Icon(Icons.add, color: Constants.myAccent,),
        backgroundColor: Constants.appThemeColor,
      ),
    );
  }
}
