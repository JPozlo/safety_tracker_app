import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class EmailSignUp extends StatefulWidget {
  final String deviceToken;
  EmailSignUp({this.deviceToken});

  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  final firestoreInstance = FirebaseFirestore.instance;
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String _imagePathFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(title: Text("Sign Up using Email")),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Enter User Name",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Enter User Name';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Enter Email",
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
                      return 'Password must be atleast 6 characters!';
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
                            registerToFb();
                          } else {
                            _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text("Please fill all fields"), duration: Duration(seconds: 8),));
                          }
                        },
                        child: Text('Sign Up', style: TextStyle(color: Constants.myAccent)),
                      ),
              )
            ]))));
  }

  void registerToFb() {
    var customEmail = emailController.text.trim().toString();
    var customName = nameController.text.trim().toString();
    var customPassword = passwordController.text.trim().toString();
    String errorMessage;

    firebaseAuth
        .createUserWithEmailAndPassword(
            email: customEmail, password: customPassword)
        .then((result) {
          result.user.sendEmailVerification().then((value) {
            print("User verification email sent");
            print("Image path is: $_imagePathFile");
            result.user.updateProfile(displayName: customName, photoURL: _imagePathFile)
                .then((value) => print("Name and photo updated successfully"))
                .catchError((err) => print("Error updating name and photo: $err"));
            DocumentReference docRef =
            firestoreInstance.collection("users").doc(result.user.uid);
            docRef.set({
              "uid": result.user.uid,
              "photoURL": _imagePathFile,
              "treks": 0,
              "email": customEmail,
              "groupId": null,
              "displayName": customName,
              "deviceToken": this.widget.deviceToken == null ? null : this.widget.deviceToken,
              "creationDate": DateTime.now(),
              "phoneNumber": null
            }).then((res) {
              addStringToPrefs(Constants.groupID, null);
              setState(() {
                isLoading = false;
              });

             _confirmEmailDialog();

            });
          }).catchError((err) => print("Error sending verification email"));

    }).catchError((err) {
      setState(() {
        isLoading = false;
      });
      switch (err.code) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
        case "account-exists-with-different-credential":
        case "email-already-in-use":
          errorMessage = "Email already in use. Go to login page.";
          break;
        case "ERROR_WRONG_PASSWORD":
        case "wrong-password":
          errorMessage = "Wrong email/password combination.";
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
    });
  }

  Future<Widget> _confirmEmailDialog(){
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Please verify email account"),
        content: Text("Verify your account via a link sent to your email and then use your credentials to sign in."),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => EmailLogin()),
                      (Route<dynamic> route) => false);
            },
            child: Text("OK"),
          ),
        ],
      ),
    );


  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
}
