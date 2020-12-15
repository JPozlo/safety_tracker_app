import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class EmailLogin extends StatefulWidget {
  @override
  _EmailLoginState createState() => _EmailLoginState();
}

class _EmailLoginState extends State<EmailLogin> {
  final firestoreInstance = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
     return Scaffold(
       key: _scaffoldKey,
        appBar: AppBar(title: Text("Sign In using Email")),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
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
                    child: TextFormField(
                      obscureText: true,
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Enter Password",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Enter Password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters!';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: RaisedButton(
                      color: Constants.appThemeColor,
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                      },
                      child: Text('Forgot Password?', style: TextStyle(color: Constants.myAccent)),
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
                          logInToFb();
                        }
                      },
                      child: Text('Sign In', style: TextStyle(color: Constants.myAccent)),
                    ),
                  ),
                ]))));
  }
  
  void logInToFb() async {
    var customEmail = emailController.text.trim().toString();
    var customPassword = passwordController.text.trim().toString();
    String errorMessage;

    if(_formKey.currentState.validate()){
      try{
        var userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: customEmail, password: customPassword);
        setState(() {
          isLoading = false;
        });

        if(userCred.user.emailVerified){
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage(uid: userCred.user.uid)),
          );
        } else {
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please verify email first before signing in"), duration: Duration(seconds: 8),));
        }
      }
      on FirebaseAuthException catch(e){
        setState(() {
          isLoading = false;
        });
        print(e.message);
        switch (e.code) {
          case "ERROR_EMAIL_ALREADY_IN_USE":
          case "account-exists-with-different-credential":
          case "email-already-in-use":
            errorMessage = "Email already used. Go to login page.";
            break;
          case "ERROR_WRONG_PASSWORD":
          case "wrong-password":
            errorMessage = "Wrong password.";
            break;
          case "ERROR_USER_NOT_FOUND":
          case "user-not-found":
            errorMessage = "No user found with this email.";
            break;
          case "ERROR_USER_DISABLED":
          case "user-disabled":
            errorMessage = "User disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
          case "operation-not-allowed":
            errorMessage = "Too many requests to log into this account.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
          case "operation-not-allowed":
            errorMessage = "Server error, please try again later.";
            break;
          case "ERROR_INVALID_EMAIL":
          case "invalid-email":
            errorMessage = "Email address is invalid.";
            break;
          default:
            errorMessage = "Login failed. Please try again.";
            break;
        }
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(errorMessage), duration: Duration(seconds: 8),));
      }
    }
    else {
      setState(() {
        isLoading = false;
      });
      _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please fill in all the fields"), duration: Duration(seconds: 8),));
    }
  }
}

