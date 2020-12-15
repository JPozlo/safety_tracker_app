import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class UpdateName extends StatefulWidget {
  @override
  _UpdateNameState createState() => _UpdateNameState();
}

class _UpdateNameState extends State<UpdateName> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Update Name"),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Update Name",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter a username';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: isLoading
                  ? CircularProgressIndicator()
                  : RaisedButton(
                      color: Constants.appThemeColor,
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          _updateUserProfile();
                        }
                      },
                      child: Text('Update', style: TextStyle(color: Constants.myAccent)),
                    ),
            )
          ],
        ),
      ),
    );
  }

  _updateUserProfile() {
    var customName = nameController.text.trim();
    var user = FirebaseAuth.instance.currentUser;
    assert(customName != null);
    UserService().updateUserName(customName).then((_) {
      setState(() {
        isLoading = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Success updating in firestore"), duration: Duration(seconds: 8),));
      user
          .updateProfile(displayName: customName)
          .then((value) =>  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Success updating fireuser"), duration: Duration(seconds: 8),)))
          .catchError((e) => _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Error updating fireuser: $e"), duration: Duration(seconds: 8),)));
    }).catchError((e) {
      setState(() {
        isLoading = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Error updating in firestore: $e"), duration: Duration(seconds: 8),));
    });
  }
}
