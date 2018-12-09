import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:memphisbjj/screens/SignUp/UploadContactInfo/index.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class UploadProfilePicScreen extends StatefulWidget {
  final bool isEdit;
  UploadProfilePicScreen({this.isEdit});

  @override
  _UploadProfilePicScreenState createState() => _UploadProfilePicScreenState();
}

class _UploadProfilePicScreenState extends State<UploadProfilePicScreen> {
  File userImage;
  bool _isLoading = false;
  bool _isDoneLoading = false;
  double _progress = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future _getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    print(tempImage.path);

    var result = await FlutterNativeImage.compressImage(
      tempImage.path,
      quality: 80,
      percentage: 50,
    );

    setState(() {
      userImage = result;
    });
  }

  Future _uploadImage() async {
    FirebaseUser user = await auth.currentUser();
    final StorageReference storageRef =
        storage.ref().child("users/${user.uid}.jpg");
    final StorageUploadTask task = storageRef.putFile(userImage);
    task.events.listen((event) {
      setState(() {
        _isLoading = true;
        _progress = event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    }, onError: (error) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(error.toString()),
        backgroundColor: Colors.red,
      ));
    });
    var url = await (await task.onComplete).ref.getDownloadURL();

    UserUpdateInfo info = new UserUpdateInfo();
    info.photoUrl = url;
    user.updateProfile(info);

    if (widget.isEdit != null && widget.isEdit) {
      Firestore.instance.collection("users").document(user.uid).updateData(
            Map.from(
              {"photoUrl": url},
            ),
          );
    }

    setState(() {
      _isDoneLoading = true;
    });
  }

  void _nextScreen() {
    if (widget.isEdit != null && widget.isEdit) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => UploadContactInfoScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: _isLoading
            ? PreferredSize(
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white,
                ),
                preferredSize: Size(MediaQuery.of(context).size.width, 5.0),
              )
            : null,
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
      child:
          _isDoneLoading ? Icon(Icons.navigate_next) : Icon(Icons.file_upload),
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
          Icon(
            Icons.camera_alt,
            size: 100.0,
          ),
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
            child: Image.file(
              userImage,
              width: 200.0,
              height: 200.0,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}
