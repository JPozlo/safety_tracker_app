import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/models/models.dart';
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class AddNewMembers extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Add Friend to group"),
      ),
      body: AddNewMember(),
    );
  }
}

class AddNewMember extends StatefulWidget {
  @override
  _AddNewMemberState createState() => _AddNewMemberState();
}

class _AddNewMemberState extends State<AddNewMember> {
  //A controller for an editable text field.
  //Whenever the user modifies a text field with an associated
  //TextEditingController, the text field updates value and the
  //controller notifies its listeners.
  var _searchview = new TextEditingController();

  bool _firstSearch = true;
  String _query = "";

  List<UserData> _nebulae;
  List<UserData> _filterList = <UserData>[];


  int _numberOfFriends = 0;

  bool isLoading = false;

  _AddNewMemberState() {
    _searchview.addListener(() {
      if (_searchview.text.isEmpty) {
        //Notify the framework that the internal state of this object has changed.
        setState(() {
          _firstSearch = true;
          _query = "";
        });
      } else {
        setState(() {
          _firstSearch = false;
          _query = _searchview.text;
        });
      }

      if (_numberOfFriends == 5) {
        setState(() {
          _numberOfFriends = 0;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _nebulae = new List<UserData>();
    FirebaseFirestore.instance.collection("users").where("uid", isNotEqualTo: FirebaseAuth.instance.currentUser.uid).get().then((val) => {
          if (val.docs.length > 0)
            {
              val.docs.forEach((element) {
                var myUser = UserData.fromDocument(element);
                if(myUser.groupId == null || myUser.groupId == ""){
                  _nebulae.add(myUser);
                } else {
                 _alreadyInGroupDialog();
                }
              })
            }
          else
            {print("Not found")}
        });
    _nebulae.sort();
  }

  Future<Widget> _alreadyInGroupDialog(){
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Can't add user to group"),
        content: Text("User is already a member of another group."),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            "Add a friend by their username",
            style: TextStyle(fontSize: 15,  color: Constants.appThemeColor, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          _createSearchView(),
          const SizedBox(
            height: 10,
          ),
          _firstSearch ? _createListView() : _performSearch(),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  //Create a SearchView
  Widget _createSearchView() {
    return new Container(
      decoration: BoxDecoration(border: Border.all(width: 1.0)),
      child: new TextField(
        controller: _searchview,
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: new TextStyle(color: Colors.grey[300]),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  //Create a ListView widget
  Widget _createListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: _nebulae.length,
          itemBuilder: (BuildContext context, int index) {
            return new Card(
              color: Colors.white,
              elevation: 5.0,
              child: new Container(
                margin: EdgeInsets.all(15.0),
                child: new Text("${_nebulae[index].displayName}"),
              ),
            );
          }),
    );
  }

  //Perform actual search
  Widget _performSearch() {
    _filterList = new List<UserData>();
    print("The user list is nebulae: $_nebulae");
    for (int i = 0; i < _nebulae.length; i++) {
      var item = _nebulae[i];

      if (item.displayName.toLowerCase().contains(_query.toLowerCase())) {
        _filterList.add(item);
      }
    }
    return _createFilteredListView();
  }

  //Create the Filtered ListView
  Widget _createFilteredListView() {
    return new Flexible(
      child: FutureBuilder(
        future: getStringPrefs(Constants.groupID),
        builder: (context, snapshot){
          Widget child;
          if(snapshot.hasData){
            child = new ListView.builder(
                itemCount: _filterList.length,
                itemBuilder: (BuildContext context, int index) {
                  return new InkWell(
                    child: Card(
                      color: Colors.white,
                      elevation: 5.0,
                      child: new Container(
                        margin: EdgeInsets.all(15.0),
                        child: new Text("${_filterList[index].displayName}"),
                      ),
                    ),
                    onTap: () => {
                      GroupService()
                          .addMember(
                          groupId: snapshot.data, userId: _filterList[index].uid)
                          .then((val) => {
                        print("Friend added"),
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "Friend Added",
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                        Future.delayed(const Duration(milliseconds: 1000),
                                () {
                              Navigator.pop(context);
                            }),
                      })
                          .catchError((e) => {print("Error due to: $e")}),
                    },
                  );
                });
                return child;
          }
          else {
            return Text("No group data yet!", style: TextStyle(color: Constants.appThemeColor, fontSize: 17) );
          }
        },
      ),
    );
  }

}
