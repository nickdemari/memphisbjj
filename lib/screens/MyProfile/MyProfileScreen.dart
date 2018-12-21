import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memphisbjj/screens/Login/index.dart';
import 'package:memphisbjj/screens/ScheduleMain/ViewSchedule/index.dart';
import 'package:memphisbjj/screens/SignUp/UploadGeneralDetails/index.dart';
import 'package:memphisbjj/screens/SignUp/UploadProfilePic/index.dart';
import 'package:memphisbjj/services/messaging.dart';
import 'package:memphisbjj/utils/UserInformation.dart';
//import 'package:memphisbjj/services/flutter_sms.dart';

class MyProfileScreen extends StatefulWidget {
  final FirebaseUser user;
  MyProfileScreen({this.user});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<Map<String, dynamic>> _msgStream;
  bool isEdit = false;

  @override
  void initState() {
    Messaging.setupFCMListeners();
    Messaging.subscribeToTopic("testing");
    _msgStream = Messaging.onFcmMessage.listen((data) {
      print(data.toString());
      var snackBar = SnackBar(content: Text(data["notification"]["body"]), backgroundColor: Colors.deepOrange,);
      _scaffoldKey.currentState.showSnackBar(snackBar);
    });
    super.initState();
  }

  @override
  void dispose() {
    _msgStream.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 0.0,
        backgroundColor: Color(0xFFe1e4e5),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("users")
            .where("firebaseUid", isEqualTo: widget.user.uid)
            .snapshots(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          DocumentSnapshot document = snapshot.data.documents[0];

          UserInformation userInfo = UserInformation(
            phoneNumber: document["information"]["phoneNumber"],
            address1: document["information"]["address1"],
            address2: document["information"]["address2"],
            city: document["information"]["city"],
            state: document["information"]["state"],
            zip: document["information"]["zip"],
          );

          return FittedBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        child: Stack(
                          children: <Widget>[
                            Container(
                                width: 125.0,
                                height: 125.0,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  image: DecorationImage(
                                      image: NetworkImage(
                                        document["photoUrl"],
                                      ),
                                      fit: BoxFit.cover),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(75.0),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 7.0,
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                            ),
                            Positioned(
                              top: 0,
                              left: 0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          UploadProfilePicScreen(
                                            isEdit: true,
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 35.5,
                                  height: 35.5,
                                  child: Icon(
                                    FontAwesomeIcons.pencilAlt,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1a256f),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(75.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 25,
                      ),
                      Column(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                            width: 175.0,
                            height: 150.0,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                AutoSizeText(
                                  document["displayName"],
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.mapMarkerAlt,
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "${document["information"]["city"]}, ${document["information"]["state"]}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.tasks,
                                      color: Colors.blueGrey,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Brazilian Jiu-Jitsu",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        child: Row(
                          children: <Widget>[
                            Text(
                              "73",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Checked-In")
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        child: Row(
                          children: <Widget>[
                            Text(
                              "930",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Ju-Jiu Points")
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  _buildProfileTools(userInfo)
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  //TODO Implement way to get a contacts phone number
//  void _sendSMS(String message, List<String> recipents) async {
//    String _result =
//        await FlutterSms.sendSMS(message: message, recipients: recipents);
//    print(_result);
//  }

  FittedBox _buildProfileTools(UserInformation userInfo) {
    return FittedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => ViewScheduleScreen(
                        user: widget.user,
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.history,
                      color: const Color(0xFF1a256f),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Class History",
                      style: TextStyle(
                          fontSize: 28,
                          color: const Color(0xFF1a256f),
                          fontFamily: "OpenSans"),
                    )
                  ],
                ),
              ),
            ),
          ),
          Divider(),
          GestureDetector(
            onTap: () async {
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text("In development"),
                  backgroundColor: Colors.blueAccent,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.userFriends,
                      color: const Color(0xFF1a256f),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Invite a friend",
                      style: TextStyle(
                          fontSize: 28,
                          color: const Color(0xFF1a256f),
                          fontFamily: "OpenSans"),
                    )
                  ],
                ),
              ),
            ),
          ),
          Divider(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => UploadGeneralDetailsScreen(
                        isEdit: true,
                        info: userInfo,
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.pencilAlt,
                      color: const Color(0xFF1a256f),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Edit Profile",
                      style: TextStyle(
                          fontSize: 28,
                          color: const Color(0xFF1a256f),
                          fontFamily: "OpenSans"),
                    )
                  ],
                ),
              ),
            ),
          ),
          Divider(),
          GestureDetector(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => LoginScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
              child: Container(
                child: Row(
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.signOutAlt,
                      color: const Color(0xFF1a256f),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Logout",
                      style: TextStyle(
                          fontSize: 28,
                          color: const Color(0xFF1a256f),
                          fontFamily: "OpenSans"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
