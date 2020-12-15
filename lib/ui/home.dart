import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class HomePage extends StatefulWidget {
  HomePage({this.uid, this.deviceToken});

  @override
  _HomePageState createState() => _HomePageState();

  final String uid;
  final String deviceToken;
  final String title = "Home";
}

class _HomePageState extends State<HomePage> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String messageTitle = "";
  String messageBody = "";
  String groupId = "";
  bool textSent = false;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser.uid).get()
    .then((value){
      setState(() {
        groupId = value.data()["groupId"];
      });
      addStringToPrefs(Constants.groupID, groupId);
    }).catchError((err){
      print("Error getting groupID: $err");
    });

    _firebaseMessaging.configure(onMessage: (message) async {
      setState(() {
        messageTitle = message['data']['title'];
        messageBody = message['notification']['body'];
        textSent = true;
      });
    }, onResume: (message) async {
      setState(() {
        messageTitle = message['data']['title'];
        textSent = true;
      });
    }, onLaunch: (message) async {
      setState(() {
        messageTitle = message['data']['title'];
        textSent = true;
      });
    });

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  @override
  void dispose() {
    super.dispose();
    textSent = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          this.widget.title,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
            ),
            onPressed: () {
              _confirmLogout();
            },
          )
        ],
      ),
      drawer: NavigateDrawer(uid: this.widget.uid),
      body: MyHomePageBody(
          deviceToken: this.widget.deviceToken, myGroupId: groupId,),
    );
  }

  Future<Widget> _confirmLogout(){
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              FirebaseAuth auth = FirebaseAuth.instance;
              auth.signOut().then((res) {
                AuthenticationService(auth).signOutGoogle();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                        (Route<dynamic> route) => false);
              });
            },
            child: Text("Logout"),
          ),
          FlatButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text("Cancel"),
          ),
        ],
      ),
    );


  }
}

class NotificationDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      DecoratedBox(
        decoration: BoxDecoration(color: Constants.appThemeColor),
        child: ListTile(
          title: Text(
            _HomePageState().messageTitle ?? "Empty Title",
            style: TextStyle(fontSize: 20, fontFamily: "Work Sans"),
          ),
          subtitle: Text(
            _HomePageState().messageBody ?? "Empty Body",
            style: TextStyle(fontFamily: "Work Sans"),
          ),
        ),
      ),
    ]));
  }
}

class MyHomePageBody extends StatelessWidget {
  MyHomePageBody({Key key, this.myGroupId, this.deviceToken}) : super(key: key);
  final String myGroupId;
  final String deviceToken;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(color: Constants.appThemeColor),
            child: ListTileTheme(
                child: Column(
              children: [
                 ListTile(
                  title: Text(
                    "You can create a group of friends with whom you can share your Trekking history and journey with.",
                    style: TextStyle(fontSize: 20, fontFamily: "Work Sans", color: Constants.lightPrimary),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateGroup()));
                      },
                      child: Text(
                        "Create New Group",
                        style: TextStyle(fontSize: 20, color: Constants.myAccent),
                      ),
                    ),
                  ],
                ),
              ],
            )),
          ),
          SizedBox(
            height: 13,
          ),
          Card(
              child: InkWell(
            splashColor: Constants.appThemeComplementaryColor,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UserRunHistory()));
            },
            child: ListTileTheme(
              tileColor: Constants.appThemeColor,
              child: ListTile(
                title: Text("View your run history",
                    style: TextStyle(fontSize: 20, fontFamily: "Work Sans", color: Constants.myAccent)),
              ),
            ),
          )),
          Card(
              child: InkWell(
            splashColor: Constants.appThemeComplementaryColor,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserGroups(
                            theGroupId: this.myGroupId,
                          )));
            },
            child: ListTileTheme(
              tileColor: Constants.appThemeColor,
              child: ListTile(
                title: Text("My Group",
                    style: TextStyle(fontSize: 20, fontFamily: "Work Sans", color: Constants.myAccent)),
              ),
            ),
          )),
          Card(
              child: InkWell(
            splashColor: Colors.blue.withBlue(30),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapPage(
                            theGroupId: myGroupId,
                            title: "Go for a run",
                          )));
            },
            child: ListTileTheme(
              tileColor: Constants.appThemeColor,
              child: ListTile(
                title: Text("Start Run",
                    style: TextStyle(fontSize: 20, fontFamily: "Work Sans", color: Constants.myAccent)),
              ),
            ),
          )),
          Card(
              child: InkWell(
            splashColor: Colors.blue.withBlue(30),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GroupTrekHistory()));
            },
            child: ListTileTheme(
              tileColor: Constants.appThemeColor,
              child: ListTile(
                title: Text("View Group Runs",
                    style: TextStyle(fontSize: 20, fontFamily: "Work Sans", color: Constants.myAccent)),
              ),
            ),
          ))
        ],
      ),
    );
  }
}

class NavigateDrawer extends StatefulWidget {
  final String uid;

  NavigateDrawer({Key key, this.uid}) : super(key: key);
  @override
  _NavigateDrawerState createState() => _NavigateDrawerState();
}

class _NavigateDrawerState extends State<NavigateDrawer> {
  FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    print("${FirebaseAuth.instance.currentUser}");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            currentAccountPicture: FutureBuilder(
              future: firestoreInstance
                  .collection("users")
                  .doc(this.widget.uid)
                  .get(),
              builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.data()['photoURL'] != null) {
                    return Image.network(snapshot.data.data()['photoURL']);
                  }
                  return CircleAvatar(
                    backgroundImage: AssetImage(
                        "images/default_profile.png"),
                  );
                } else {
                  return CircleAvatar(
                    backgroundImage: AssetImage(
                        "images/default_profile.png"),
                  );
                }
              },
            ),
            accountEmail: FutureBuilder(
                future:
                    firestoreInstance.collection("users").doc(widget.uid).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.data()['email']);
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
            accountName: FutureBuilder(
                future:
                    firestoreInstance.collection("users").doc(widget.uid).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.data()['displayName']);
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
            decoration: BoxDecoration(
              color: Constants.appThemeColor,
            ),
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.home, color: Constants.appThemeColor),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(uid: widget.uid)),
              ),
            ),
            title: Text('Home',  style: TextStyle(color: Constants.appThemeColor)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(uid: widget.uid)),
              );
            },
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.account_box, color: Constants.appThemeColor),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => UpdateProfile()));
              },
            ),
            title: Text('Account Update', style: TextStyle(color: Constants.appThemeColor)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UpdateProfile()));
            },
          ),
        ],
      ),
    );
  }
}
