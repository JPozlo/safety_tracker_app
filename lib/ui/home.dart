import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/services/auth_service.dart';
import 'package:safety_tracker_app/ui/create_group.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class HomePage extends StatelessWidget {
  HomePage({this.uid});
  final String uid;
  final String title = "Home";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            onPressed: () {
              FirebaseAuth auth = FirebaseAuth.instance;
              auth.signOut().then((res) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                    (Route<dynamic> route) => false);
              });
            },
          )
        ],
      ),
      drawer: NavigateDrawer(uid: this.uid),
      body: MyHomePageBody(),
    );
  }
}

class MyHomePageBody extends StatelessWidget {
  MyHomePageBody({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTileTheme(
            child: const ListTile(
              title: Text("Create a Group"),
              subtitle: Text(
                  "You can create a group of up to 5 friends with whom you can share your Trekking history and journey with."),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CreateGroup()));
                  }, child: const Text("Create New Group", style: TextStyle(fontSize: 20),)),
            ],
          ),
          SizedBox(height: 13,),
          Card(
            child: InkWell(
              splashColor: Colors.blue.withBlue(30),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => UserRunHistory()));

              },
              child:  ListTileTheme(
                tileColor: Colors.cyan,
                child: const ListTile(
                  title: Text("View your run history"),
                ),
              ),
            )
          ),
          Card(
              child: InkWell(
                splashColor: Colors.blue.withBlue(30),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserGroups()));

                },
                child:  ListTileTheme(
                  tileColor: Colors.cyan,
                  child: const ListTile(
                    title: Text("My Group"),
                  ),
                ),
              )
          )
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
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: FutureBuilder(
                future:
                    firestoreInstance.collection("users").doc(widget.uid).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data['email']);
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
            accountName: FutureBuilder(
                future:
                    firestoreInstance.collection("users").doc(widget.uid).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data['name']);
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.home, color: Colors.black),
              onPressed: () => null,
            ),
            title: Text('Home'),
            onTap: () {
              print(widget.uid);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(uid: widget.uid)),
              );
            },
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.settings, color: Colors.black),
              onPressed: () => null,
            ),
            title: Text('Settings'),
            onTap: () {
              print(widget.uid);
            },
          ),
        ],
      ),
    );
  }
}
