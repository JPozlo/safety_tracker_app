import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class SignInPage extends StatefulWidget {
  final String deviceToken;

  SignInPage({this.deviceToken});

  @override
  _EmailLogInState createState() => _EmailLogInState();
}

class _EmailLogInState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sign In"),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Sign In",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      fontFamily: 'Roboto')),
            ),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: SignInButton(
                  Buttons.Email,
                  text: "Sign in with Email",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmailLogin()),
                    );
                  },
                )),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: SignInButton(
                  Buttons.Google,
                  text: "Sign in with Google",
                  onPressed: () {
                    AuthenticationService(FirebaseAuth.instance)
                        .signInWithGoogle()
                        .then((result) {
                      DocumentReference docRef = FirebaseFirestore.instance
                          .collection("users")
                          .doc(result.user.uid);
                      docRef.set({
                        "uid": result.user.uid,
                        "photoURL": result.user.photoURL,
                        "treks": 0,
                        "email": result.user.email,
                        "deviceToken": this.widget.deviceToken == null ? null : this.widget.deviceToken,
                        "displayName": result.user.displayName,
                        "creationDate": DateTime.now(),
                        "phoneNumber": null
                      }, SetOptions(merge: true));
                      if (result != null) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return HomePage(uid: result.user.uid);
                        }));
                      }
                    });
                  },
                )),
            const SizedBox(
              height: 15,
            ),
            Text("Don't have an account? Sign up"),
            const SizedBox(
              height: 5,
            ),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                    color: Constants.appThemeColor,
                    child: Text("Sign Up",
                        style: TextStyle(color: Constants.myAccent)),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage(deviceToken: this.widget.deviceToken)),
                      );
                    }))
          ]),
        ));
  }
}
