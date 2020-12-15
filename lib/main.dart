import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safety_tracker_app/models/models.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:safety_tracker_app/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashscreen/splashscreen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

User myUser;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String messageTitle = "";
  String messageBody = "";
  String deviceToken = "";

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
     addStringToPrefs(Constants.deviceToken, token);
     deviceToken = token;
     if(myUser != null){
       _firestore.collection("users").doc(FirebaseAuth.instance.currentUser.uid)
           .set({"deviceToken": token}, SetOptions(merge: true)).then((value) => {
         print("Successfully saved token to firestore")
       }).catchError((onError) => {
         print("Error saving token to firestore due to: $onError")
       });
       print("Value of device token: ${getStringPrefs(Constants.deviceToken)}");
     }
    });


  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(create: (_) => AuthenticationService(FirebaseAuth.instance),),
        StreamProvider(create: (context) => context.read<AuthenticationService>().authStateChanges)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Maps',
        theme: Constants.mainTheme,
        home: AuthenticationWrapper(deviceToken: deviceToken,),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({
    Key key,
    this.deviceToken
}): super(key: key);

  final String deviceToken;

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    myUser = firebaseUser;


    return new SplashScreen(
        seconds: 5,
      navigateAfterSeconds: firebaseUser != null ? HomePage(uid: firebaseUser.uid, deviceToken: deviceToken) : SignInPage(deviceToken: deviceToken,) ,
      title: new Text("Welcome to Walk With Friends!", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
      image: Image.asset('images/splash_icon.png', fit: BoxFit.scaleDown,),
      backgroundColor: Constants.appThemeColor,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("Going for walks will never be the same again if you are alone."),
        loaderColor: Constants.appThemeComplementaryColor);
  }
}


