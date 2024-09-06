import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memphisbjj/screens/login/login-screen.dart';
import 'package:memphisbjj/screens/profile/member-dependents/member-dependents.dart';
import 'package:memphisbjj/screens/schedule-feature/view-schedule-screen/view-schedule-screen.dart';
import 'package:memphisbjj/screens/sign-up/upload-general-details-screen/upload-general-details-screen.dart';
import 'package:memphisbjj/screens/sign-up/upload-profile-picture-screen/upload-profile-picture-screen.dart';
import 'package:memphisbjj/services/messaging.dart';
import 'package:memphisbjj/utils/user-information.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<Map<String, dynamic>>? _msgStream;

  @override
  void initState() {
    super.initState();
    _subscribeToFCM();
  }

  @override
  void dispose() {
    _msgStream
        ?.cancel(); // Properly cancel the subscription to prevent memory leaks
    super.dispose();
  }

  /// Subscribes to FCM topic and listens for incoming messages
  void _subscribeToFCM() {
    Messaging.subscribeToTopic("testing");
    _msgStream = Messaging.onFcmMessage.listen((data) {
      final alert = Messaging.getAlert(data);
      // Use ScaffoldMessenger to show SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(alert),
          backgroundColor: Colors.deepOrange,
        ),
      );
      _msgStream?.cancel(); // Cancel after receiving a message if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0.0,
        backgroundColor: const Color(0xFFe1e4e5),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("firebaseUid", isEqualTo: widget.user.uid)
            .snapshots(),
        builder: (
          BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No user data found."));
          }

          DocumentSnapshot document = snapshot.data!.docs.first;

          UserInformation userInfo = UserInformation(
            phoneNumber: document["information"]["phoneNumber"] ?? '',
            address1: document["information"]["address1"] ?? '',
            address2: document["information"]["address2"] ?? '',
            city: document["information"]["city"] ?? '',
            state: document["information"]["state"] ?? '',
            zip: document["information"]["zip"] ?? '',
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _buildProfileImage(document["photoUrl"]),
                    const SizedBox(width: 25),
                    _buildUserInfo(document),
                  ],
                ),
                const Divider(),
                _buildStatistics(),
                const Divider(),
                _buildProfileTools(userInfo),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the profile image with an edit button overlay
  Widget _buildProfileImage(String photoUrl) {
    return Stack(
      children: <Widget>[
        Container(
          width: 125.0,
          height: 125.0,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            image: DecorationImage(
              image: NetworkImage(photoUrl),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(75.0),
            boxShadow: const [
              BoxShadow(
                blurRadius: 7.0,
                color: Colors.black26,
              )
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: GestureDetector(
            onTap: _navigateToEditProfilePic,
            child: Container(
              width: 35.5,
              height: 35.5,
              decoration: const BoxDecoration(
                color: Color(0xFF1a256f),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.pencil,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Navigates to the UploadProfilePicScreen
  void _navigateToEditProfilePic() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => UploadProfilePicScreen(
          isEdit: true,
        ),
      ),
    );
  }

  /// Builds the user's information section
  Widget _buildUserInfo(DocumentSnapshot document) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      width: 175.0,
      height: 150.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AutoSizeText(
            document["displayName"] ?? 'No Name',
            maxLines: 1,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              const Icon(
                FontAwesomeIcons.locationDot,
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 10),
              Text(
                "${document["information"]["city"] ?? 'City'}, ${document["information"]["state"] ?? 'State'}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: <Widget>[
              const Icon(
                FontAwesomeIcons.listCheck,
                color: Colors.blueGrey,
              ),
              const SizedBox(width: 10),
              const Text(
                "Brazilian Jiu-Jitsu",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the statistics section (e.g., Checked-In, Ju-Jiu Points)
  Widget _buildStatistics() {
    // Replace with actual data as needed
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildStatisticItem("73", "Checked-In"),
        _buildStatisticItem("930", "Ju-Jiu Points"),
      ],
    );
  }

  /// Builds individual statistic items
  Widget _buildStatisticItem(String count, String label) {
    return Row(
      children: <Widget>[
        Text(
          count,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5),
        Text(label),
      ],
    );
  }

  /// Builds the profile tools section with navigation options
  Widget _buildProfileTools(UserInformation userInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildProfileToolItem(
          icon: FontAwesomeIcons.clockRotateLeft,
          label: "Class History",
          onTap: _navigateToClassHistory,
        ),
        const Divider(),
        _buildProfileToolItem(
          icon: FontAwesomeIcons.userGroup,
          label: "Manage Dependents",
          onTap: _navigateToManageDependents,
        ),
        const Divider(),
        _buildProfileToolItem(
          icon: FontAwesomeIcons.pencil,
          label: "Edit Profile",
          onTap: () => _navigateToEditProfile(userInfo),
        ),
        const Divider(),
        _buildProfileToolItem(
          icon: FontAwesomeIcons.rightFromBracket,
          label: "Logout",
          onTap: _logout,
        ),
      ],
    );
  }

  /// Builds individual profile tool items
  Widget _buildProfileToolItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        child: Row(
          children: <Widget>[
            Icon(
              icon,
              color: const Color(0xFF1a256f),
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(
                fontSize: 28,
                color: Color(0xFF1a256f),
                fontFamily: "OpenSans",
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigates to the Class History screen
  void _navigateToClassHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ViewScheduleScreen(
          user: widget.user,
          getAll: true,
        ),
      ),
    );
  }

  /// Navigates to the Manage Dependents screen
  void _navigateToManageDependents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => MemberDependentsScreen(
          parentFbUid: widget.user.uid,
        ),
      ),
    );
  }

  /// Navigates to the Edit Profile screen
  void _navigateToEditProfile(UserInformation userInfo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => UploadGeneralDetailsScreen(
          isEdit: true,
          info: userInfo,
        ),
      ),
    );
  }

  /// Handles user logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => LoginScreen(),
      ),
    );
  }
}
