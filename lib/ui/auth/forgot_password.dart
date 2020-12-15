import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPage createState() => _ForgotPasswordPage();

}

class _ForgotPasswordPage extends State<ForgotPasswordPage>{
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Password Reset"),),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Enter Email Address",
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Enter Email Address';
                      } else if (!value.contains('@')) {
                        return 'Please enter a valid email address!';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child:  RaisedButton(
                    color: Constants.appThemeColor,
                    onPressed: () {
                      if (_formKey.currentState.validate()) {

                        _sendPassReset();
                      }
                    },
                    child: Text('Submit', style: TextStyle(color: Constants.myAccent)),
                  ),
                ),

              ]


          ),
        ),
      ),
    );
  }

  void _sendPassReset(){
    String email = emailController.text.trim().toString();
    _firebaseAuth.sendPasswordResetEmail(email: email).then((val){
      emailController.text = "";
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success"),
              content: Text("Link sent to email successfully"),
              actions: [
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });

    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Link not sent to email"),
              actions: [
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });

  }
}
