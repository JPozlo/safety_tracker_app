import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddNewMembers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
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

  List<String> _nebulae;
  List<String> _filterList = <String>[];
  List<String> _addedFriends = <String>[];

  bool _maxFriends = false;
  int _maxNumberOfFriends = 5;
  int _numberOfFriends = 0;

  bool isLoading = false;

  _AddNewMemberState(){
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

      if(_numberOfFriends == 5){
        setState(() {
          _maxFriends = true;
          _numberOfFriends = 0;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _nebulae = new List<String>();
    _nebulae = [
      "Orion",
      "Boomerang",
      "Cat's Eye",
      "Pelican",
      "Ghost Head",
      "Witch Head",
      "Snake",
      "Ant",
      "Bernad 68",
      "Flame",
      "Eagle",
      "Horse Head",
      "Elephant's Trunk",
      "Butterfly"
    ];
    _nebulae.sort();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text("Add a friend by their username", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
          const SizedBox(height: 20,),
          _createSearchView(),
          const SizedBox(height: 10,),
          _firstSearch ? _createListView() : _performSearch(),
          const SizedBox(height: 20,),
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
                child: new Text("${_nebulae[index]}"),
              ),
            );
          }),
    );
  }

  //Perform actual search
  Widget _performSearch() {
    _filterList = new List<String>();
    for (int i = 0; i < _nebulae.length; i++) {
      var item = _nebulae[i];

      if (item.toLowerCase().contains(_query.toLowerCase())) {
        _filterList.add(item);
      }
    }
    return _createFilteredListView();
  }

  //Create the Filtered ListView
  Widget _createFilteredListView() {
    return new Flexible(
      child: new ListView.builder(
          itemCount: _filterList.length,
          itemBuilder: (BuildContext context, int index) {
            return new InkWell(
              child: Card(
                color: Colors.white,
                elevation: 5.0,
                child: new Container(
                  margin: EdgeInsets.all(15.0),
                  child: new Text("${_filterList[index]}"),
                ),
              ),
              onTap: () => {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text("Friend Added", style: TextStyle(color: Colors.white),),)),
                Future.delayed(const Duration(milliseconds: 1000), (){
                  Navigator.pop(context);
                }),
              },
            );
          }),
    );
  }
}

