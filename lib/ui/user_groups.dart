import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/ui/views.dart';

class UserGroups extends StatefulWidget {
  @override
  _UserGroupsState createState() => _UserGroupsState();
}

class _UserGroupsState extends State<UserGroups> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Name")
      ),
      body: GroupMembers(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewMembers()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepOrangeAccent,
      ),
    );
  }
}
