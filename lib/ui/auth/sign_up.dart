import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:safety_tracker_app/utils/utils.dart';


class SignUpPage extends StatelessWidget {
  final String title = "Sign Up";
  final String deviceToken;

  SignUpPage({this.deviceToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(this.title),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
              Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text("Join Us",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      fontFamily: 'Roboto')),
            ),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: SignInButton(
                  Buttons.Email,
                  text: "Sign up with Email",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EmailSignUp(deviceToken: this.deviceToken,)),
                    );
                  },
                )),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: SignInButton(
                  Buttons.Google,
                  text: "Sign up with Google",
                  onPressed: () {
                    AuthenticationService(FirebaseAuth.instance).signInWithGoogle().then((result ){
                    DocumentReference docRef = FirebaseFirestore.instance.collection("users").doc(result.user.uid);
                    docRef.set({
                      "uid": result.user.uid,
                      "photoURL": result.user.photoURL,
                      "treks": 0,
                      "email": result.user.email,
                      "deviceToken": deviceToken,
                      "displayName": result.user.displayName,
                      "creationDate": DateTime.now(),
                      "phoneNumber": null
                    }, SetOptions(merge: true));
                      if(result != null){
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context){
                            return HomePage(uid: result.user.uid);
                          }
                        ));
                      }
                    });
                  },
                )),
                const SizedBox(height: 15 ,),
                Text("Already have an account? Sign in"),
                const SizedBox(height: 5 ,),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                  color: Constants.appThemeColor,
                    child: Text("Sign In",
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Constants.myAccent)),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage(deviceToken: this.deviceToken,)),
                              (Route<dynamic> route) => false);
                    }))
          ]),
        ));

  }
}
