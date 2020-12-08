import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:splashscreen/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  ThemeData appTheme = ThemeData(
      primaryColor: Colors.purpleAccent,
      fontFamily: 'Oxygen'
  );

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
        theme: appTheme,
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({
    Key key,
}): super(key: key);
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();

    return new SplashScreen(
        seconds: 5,
      navigateAfterSeconds: firebaseUser != null ? HomePage() : SignInPage() ,
      title: new Text("Welcome to Walk With Friends!", style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),),
      image: Image.asset('images/driving_pin.png', fit: BoxFit.scaleDown,),
      backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        onClick: () => print("flutter"),
        loaderColor: Colors.red);
  }
}


