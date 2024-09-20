import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:memphisbjj/screens/onboarding/screens/upload-contact-info-screen/upload-contact-info-screen.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class UploadProfilePicScreen extends StatefulWidget {
  final bool isEdit;
  const UploadProfilePicScreen({Key? key, this.isEdit = false})
      : super(key: key);

  @override
  _UploadProfilePicScreenState createState() => _UploadProfilePicScreenState();
}

class _UploadProfilePicScreenState extends State<UploadProfilePicScreen> {
  File? userImage;
  bool _isLoading = false;
  bool _isDoneLoading = false;
  double _progress = 0.0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    print(pickedFile.path);

    final compressedImage = await FlutterNativeImage.compressImage(
      pickedFile.path,
      quality: 80,
      percentage: 50,
    );

    setState(() {
      userImage = File(compressedImage.path);
    });
  }

  Future<void> _uploadImage() async {
    final user = auth.currentUser;
    if (user == null || userImage == null) return;

    final storageRef = storage.ref().child('users/${user.uid}.jpg');
    final uploadTask = storageRef.putFile(userImage!);

    uploadTask.snapshotEvents.listen(
      (event) {
        setState(() {
          _isLoading = true;
          _progress =
              event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
        });
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      },
    );

    final snapshot = await uploadTask;
    final url = await snapshot.ref.getDownloadURL();

    user.updateProfile(photoURL: url);

    if (widget.isEdit) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'photoUrl': url},
      );
    }

    setState(() {
      _isDoneLoading = true;
    });
  }

  void _nextScreen() {
    if (widget.isEdit) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const UploadContactInfoScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: Size(MediaQuery.of(context).size.width, 5.0),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.white,
                ),
              )
            : null,
      ),
      body: Center(
        child: userImage == null ? _needsUpload() : _enableUpload(),
      ),
      floatingActionButton: userImage == null ? _addPhoto() : _uploadPhoto(),
    );
  }

  FloatingActionButton _addPhoto() {
    return FloatingActionButton(
      onPressed: _getImage,
      tooltip: 'Get Profile Picture',
      child: const Icon(Icons.add),
    );
  }

  FloatingActionButton _uploadPhoto() {
    return FloatingActionButton(
      onPressed: _isDoneLoading ? _nextScreen : _uploadImage,
      tooltip: _isDoneLoading ? 'Next: Update Contact Info' : 'Upload Picture',
      child: _isDoneLoading
          ? const Icon(Icons.navigate_next)
          : const Icon(Icons.file_upload),
    );
  }

  Widget _needsUpload() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.camera_alt,
          size: 100.0,
        ),
        Text('Add Profile Picture'),
      ],
    );
  }

  Widget _enableUpload() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(200.0),
          child: Image.file(
            userImage!,
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
