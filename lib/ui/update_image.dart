import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:safety_tracker_app/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safety_tracker_app/services/services.dart';

class UpdateImage extends StatefulWidget {
  @override
  _UpdateImageState createState() => _UpdateImageState();
}

class _UpdateImageState extends State<UpdateImage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  File imageFile;
  String _uploadedFileURL;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Image"),),
      body: Form(
        key: _formKey,
          child: Center(
            child: Column(
              children: [
                _setImageView(),
                   Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: RaisedButton(
                      color: Constants.appThemeColor,
                      onPressed: () {
                        _openGallery(context);
                      },
                      child: _uploadedFileURL == null ? Text('Load Image',  style: TextStyle(color: Constants.myAccent)) : Text('Image Updated',  style: TextStyle(color: Constants.myAccent)),
                    ),
                  ),
              ],
            ),
          ),
      ),
    );
  }

  Widget _setImageView() {
    if (imageFile != null) {
      return Image.file(imageFile, width: 500, height: 500);
    } else {
      return Text("Please select an image");
    }
  }

  // Future<void> _showSelectionDialog(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //             title: Text("From where do you want to take the photo?"),
  //             content: SingleChildScrollView(
  //               child: ListBody(
  //                 children: <Widget>[
  //                   GestureDetector(
  //                     child: Text("Gallery"),
  //                     onTap: () {
  //                       _openGallery(context);
  //                     },
  //                   ),
  //                   Padding(padding: EdgeInsets.all(8.0)),
  //                   GestureDetector(
  //                     child: Text("Camera"),
  //                     onTap: () {
  //                       _openCamera(context);
  //                     },
  //                   )
  //                 ],
  //               ),
  //             ));
  //       });
  // }

  Future<void> _showFeedback(BuildContext context, String title, String message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(title),
              content: Text(message),
          actions: [
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],);
        });
  }

  void _openGallery(BuildContext context) async {
    var picture = await ImagePicker.pickImage(source: ImageSource.gallery);
    this.setState(() {
      imageFile = picture;
    });
    uploadFile();
  }

  // void _openCamera(BuildContext context) async {
  //   var picture = await ImagePicker.pickImage(source: ImageSource.camera);
  //   this.setState(() {
  //     imageFile = picture;
  //   });
  //   uploadFile();
  //   Navigator.of(context).pop();
  // }

  Future uploadFile() async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('profiles/${Path.basename(imageFile.path)}');
    UploadTask uploadTask = storageReference.putFile(imageFile);
    await uploadTask;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      _updateUserProfile(fileURL);
      setState(() {
        _uploadedFileURL = fileURL;
      });
    });
  }

  _updateUserProfile(String fileURL){
    var user = FirebaseAuth.instance.currentUser;
    assert(fileURL != null);
    UserService().updateUserPhoto(fileURL).then((_) {
      setState(() {
        isLoading = false;
      });
      user.updateProfile(photoURL: fileURL).then((value) =>   _showFeedback(context, "Success", "Image successfully updated"))
          .catchError((e) =>  _showFeedback(context, "Error", "There was an issue updating the image"));
    }).catchError((e)  {
      setState(() {
        isLoading = false;
      });
      _showFeedback(context, "Error", "There was an issue updating the image");
    });
  }
}
