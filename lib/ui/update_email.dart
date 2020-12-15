import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class UpdateEmail extends StatefulWidget {
  @override
  _UpdateEmailState createState() => _UpdateEmailState();
}

class _UpdateEmailState extends State<UpdateEmail> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("Update Email"),),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Update Email",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // The validator receives the text that the user has entered.
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Enter an Email Address';
                  } else if (!value.contains('@')) {
                    return 'Please enter a valid email address';
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
                child: Text('Update',  style: TextStyle(color: Constants.myAccent)),
              ),
            )
          ],
        ),
      ),
    );
  }

  _updateUserProfile(){
    var customEmail = emailController.text.trim();
    var user = FirebaseAuth.instance.currentUser;
    assert(customEmail != null);
    UserService().updateUserEmail(customEmail).then((_) {
      setState(() {
        isLoading = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Success updating in firestore"), duration: Duration(seconds: 8),));
      user.updateEmail(customEmail).then((value) =>  _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Success updating fireuser"), duration: Duration(seconds: 8),)))
          .catchError((e) => _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Error updating fireuser: $e"), duration: Duration(seconds: 8),)));
    }).catchError((e) {
    setState(() {
    isLoading = false;
    });
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Error updating in firestore: $e"), duration: Duration(seconds: 8),));
    });
  }
}
