import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_tracker_app/models/models.dart';

class CreateGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
      ),
      body: CreateGroupForm(),
    );
  }
}

class CreateGroupForm extends StatefulWidget {
  @override
  _CreateGroupFormState createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.all(20.0),
                      child: TextFormField(
                        controller: groupNameController,
                        decoration: InputDecoration(
                          labelText: "Enter Group Name",
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Enter valid group name';
                          } else if (value.length < 3) {
                            return 'Please enter at least 3 characters for he group name!';
                          }
                          return null;
                        },
                      ))
                ],
              ),
            ),
          ),
          _saveGroup()
        ],
      ),
    );
  }

  Widget _saveGroup(){
    return new RaisedButton(onPressed: (){
      if(_formKey.currentState.validate()){
        Scaffold.of(context)
            .showSnackBar(SnackBar(content: Text("Group Saved", style: TextStyle(color: Colors.white),),));
        Future.delayed(new Duration(milliseconds: 1000), (){
          Navigator.pop(context);
        });
      }
      // Create group and save in database
    }, child: Text("Create Group"),
      color: Colors.teal,
    );
  }

}
