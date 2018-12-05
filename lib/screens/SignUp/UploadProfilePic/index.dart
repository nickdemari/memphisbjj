import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:memphisbjj/screens/SignUp/UploadContactInfo/index.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class UploadProfilePicScreen extends StatefulWidget {
  @override
  _UploadProfilePicScreenState createState() => _UploadProfilePicScreenState();
}

class _UploadProfilePicScreenState extends State<UploadProfilePicScreen> {
  File userImage;
  bool _isLoading = false;
  bool _isDoneLoading = false;
  double _progress;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future _getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    var result = await FlutterImageCompress.compressAndGetFile(tempImage.absolute.path, tempImage.absolute.path, quality: 50);

    setState(() {
      userImage = result;
    });
  }

  Future _uploadImage() async {
    var user = await FirebaseAuth.instance.currentUser();
    final StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("users/${user.uid}.jpg");
    final StorageUploadTask task = firebaseStorageRef.putFile(userImage);
    task.events.listen((event) {
      setState(() {
        _isLoading = true;
        _progress = event.snapshot.bytesTransferred.toDouble() / event.snapshot.totalByteCount.toDouble();
      });
      print(event.snapshot.storageMetadata.path);
    }, onError: (error) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(content: new Text(error.toString()), backgroundColor: Colors.red,) );
    });
    var test = await (await task.onComplete).ref.getDownloadURL();
    print(test);

    UserUpdateInfo info = new UserUpdateInfo();
    info.photoUrl = test;
    user.updateProfile(info);

    setState(() {
      _isDoneLoading = true;
    });
  }

  void _nextScreen() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => UploadContactInfoScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: _isLoading ? PreferredSize(
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.white,
          ),
          preferredSize: Size(MediaQuery.of(context).size.width, 5.0),
        ) : null,
      ),
      body: Center(
        child: userImage == null ? needsUpload() : enableUpload(),
      ),
      floatingActionButton: userImage == null ? addPhoto() : uploadPhoto(),
    );
  }

  FloatingActionButton addPhoto() {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: _getImage,
      tooltip: "Get Profile Picture",
    );
  }

  FloatingActionButton uploadPhoto() {
    return FloatingActionButton(
      child: _isDoneLoading ? Icon(Icons.navigate_next) : Icon(Icons.file_upload),
      onPressed: _isDoneLoading ? _nextScreen : _uploadImage,
      tooltip: _isDoneLoading ? "Next: Update Contact Info" : "Upload Picture",
    );
  }

  Widget needsUpload() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.camera_alt, size: 100.0,),
          Container(
            child: Text("Add Profile Picture"),
          )
        ],
      ),
    );
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(200.0),
            child: Image.file(userImage, width: 200.0, height: 200.0, fit: BoxFit.cover,),
          ),
        ],
      ),
    );
  }
}