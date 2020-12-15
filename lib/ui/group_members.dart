import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/ui/user_group_run_history.dart';
import 'package:safety_tracker_app/ui/views.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class GroupMembers extends StatefulWidget {
  @override
  _GroupMembers createState() => _GroupMembers();
}

class _GroupMembers extends State<GroupMembers> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new FutureBuilder(
          future: getStringPrefs(Constants.groupID),
          builder: (context, snapshot) {
            Widget child;
            if (snapshot.hasData) {
              print("Userdata: ${snapshot.data}");
              child = StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where("groupId", isEqualTo: snapshot.data)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}', style: TextStyle(color: Constants.appThemeColor, fontSize: 17));
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Container(
                        child: CircularProgressIndicator(
                          backgroundColor: Constants.appThemeColor,
                          strokeWidth: 1,
                        )
                      );
                    } else if(snapshot.connectionState == ConnectionState.active){
                      if (snapshot.hasData) {
                        return ListView(
                          children:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                            if (document.exists) {
                              return new ListTile(
                                onTap: (){
                                  var userID = document['uid'];
                                  var username = document['displayName'];
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserGroupRunHistory(uid: userID, username: username,)));
                                },
                                leading: Icon(
                                  Icons.person,
                                  color: Constants.appThemeColor,
                                  size: 42,
                                ),
                                title: new Text(
                                  "${document['displayName']}",
                                  style: TextStyle(
                                      color: Constants.appThemeColor,
                                      fontSize: 24),
                                ),
                                subtitle: new Text(
                                  "${document['email']}",
                                  style: TextStyle(
                                      color: Constants.appThemeColor,
                                      fontSize: 17),
                                ),
                                trailing: Icon(Icons.arrow_forward_ios, color: Constants.appThemeColor,),
                              );
                            }
                            return new Text("No group data yet!");
                          }).toList(),
                        );
                      } else {
                        return Text("No group data yet!", style: TextStyle(color: Constants.appThemeColor, fontSize: 17));
                      }
                    }
                    return Text("No group data yet!", style: TextStyle(color: Constants.appThemeColor, fontSize: 17));
                  });
              return child;
            } else {
              return Text("No group data yet!", style: TextStyle(color: Constants.appThemeColor, fontSize: 17) );
            }
          }),
    );
  }

}
