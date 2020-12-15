import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:safety_tracker_app/utils/constants.dart';

class UpdateProfile extends StatefulWidget {
  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Profile"),),
      body: Center(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    color: Constants.appThemeColor,
                    child: Text("Update Image", style: TextStyle(color: Constants.myAccent)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateImage()),
                      );
                    },
                  )),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    color: Constants.appThemeColor,
                    child: Text("Update Name", style: TextStyle(color: Constants.myAccent)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateName()),
                      );
                    },
                  )),
              Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    color: Constants.appThemeColor,
                    child: Text("Update Email", style: TextStyle(color: Constants.myAccent)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UpdateEmail()),
                      );
                    },
                  )),
            ],
          ),
      ),
    );
  }

}


