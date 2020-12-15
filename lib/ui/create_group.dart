import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/models/models.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/utils/constants.dart';

class CreateGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Create Group",
        ),
      ),
      body: CreateGroupForm(),
    );
  }
}

class CreateGroupForm extends StatefulWidget {
  @override
  _CreateGroupFormState createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  TextEditingController groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: groupNameController,
                        decoration: InputDecoration(
                          labelText: "Enter Group Name",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter valid group name';
                          } else if (value.length < 3) {
                            return 'Please enter at least 3 characters for the group name!';
                          }
                          return null;
                        },
                      ))
                ],
              ),
            ),
          ),
          _saveGroup()
        ],
      ),
    );
  }

  Widget _saveGroup() {
    return new RaisedButton(
      onPressed: () {
        if (_formKey.currentState.validate()) {
          setState(() {
            isLoading = true;
          });
          saveNewGroup();
        }
        // Create group and save in database

      },
      child: Text("Create Group", style: TextStyle(color: Constants.myAccent)),
      color: Constants.appThemeColor,
    );
  }

  void saveNewGroup() {
    UserData user;
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      user = UserData.fromDocument(value);
      if (user.groupId == null || user.groupId == "") {
        GroupService().addGroup(name: groupNameController.text.trim().toString());
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
            "Group Saved",
            style: TextStyle(color: Colors.white),
          ),
        ));
        isLoading = false;
        Future.delayed(new Duration(milliseconds: 1000), () {
          Navigator.pop(context);
        });
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
            "You are already in a group. Can't be in more than 1 group",
            style: TextStyle(color: Colors.white),
          ),
        ));
      }
    }).catchError((err) => print("Error getting group id: $err"));
  }
}
