import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memphisbjj/screens/about/about-screen.dart';
import 'package:memphisbjj/screens/instructors/instructers-screen.dart';
import 'package:memphisbjj/screens/login/login-screen.dart';
import 'package:memphisbjj/screens/profile/profile-screen.dart';
import 'package:memphisbjj/screens/schedule-feature/view-schedule-screen/view-schedule-screen.dart';
import 'package:memphisbjj/screens/schedule-feature/schedule-screen.dart';
import 'package:memphisbjj/screens/styles/styles-screen.dart';
import 'package:memphisbjj/services/messaging.dart';
import 'package:memphisbjj/theme/style.dart';
import 'package:memphisbjj/utils/user-item.dart';

class HomeScreen extends StatefulWidget {
  final UserItem? user;
  final User? anonymousUser;

  const HomeScreen({Key? key, this.user, this.anonymousUser}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  StreamSubscription<Map<String, dynamic>>? _msgStream;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    print("HOME");
    Messaging.subscribeToTopic("testing");
    _msgStream = Messaging.onFcmMessage.listen((data) {
      var alert = Messaging.getAlert(data);
      Messaging.cancelFcmMessaging();
      var snackBar = SnackBar(
        content: Text(alert),
        backgroundColor: Colors.deepOrange,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      _msgStream?.cancel();
    });
  }

  @override
  void dispose() {
    _msgStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    if (widget.anonymousUser != null && widget.anonymousUser!.isAnonymous) {
      list =
          _createMemberList(context: context, widget: widget, msg: _msgStream);
    } else if (widget.user != null && widget.user!.roles.admin) {
      list =
          _createAdminList(context: context, widget: widget, msg: _msgStream);
    } else if (widget.user != null && widget.user!.roles.subscriber) {
      list =
          _createMemberList(context: context, widget: widget, msg: _msgStream);
    }

    return Scaffold(
      key: _globalKey,
      floatingActionButton: widget.anonymousUser != null
          ? Container(
              height: 85.0,
              width: 85.0,
              child: FloatingActionButton(
                child: Text("SIGN UP"),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            floating: true,
            title: Text("Memphis Judo & Jiu-Jitsu"),
            expandedHeight: 175.0,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Image.asset(
                "assets/app-drawer-main.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverFixedExtentList(
            itemExtent: 175.0,
            delegate: SliverChildListDelegate(list),
          ),
        ],
      ),
    );
  }
}

List<Widget> _createAdminList({
  required BuildContext context,
  required HomeScreen widget,
  required StreamSubscription<Map<String, dynamic>>? msg,
}) {
  return [
    _buildHomeCard(
      context: context,
      title: "SCHEDULE",
      imagePath: "assets/member-benefits.jpg",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScheduleScreen(
              user: widget.user!.fbUser,
              locationName: "Bartlett",
            ),
          ),
        );
      },
    ),
    _buildHomeCard(
      context: context,
      title: "JITSU LABS",
      imagePath: "assets/styles.jpg",
    ),
    _buildHomeCard(
      context: context,
      title: "INSTRUCTORS",
      imagePath: "assets/about-us.jpg",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InstructorsScreen(),
          ),
        );
      },
    ),
    _buildHomeCard(
      context: context,
      title: "STYLES",
      imagePath: "assets/styles.jpg",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StylesScreen(),
          ),
        );
      },
    ),
    _buildProfileTools(context, widget),
  ];
}

List<Widget> _createMemberList({
  required BuildContext context,
  required HomeScreen widget,
  required StreamSubscription<Map<String, dynamic>>? msg,
}) {
  return [
    _buildHomeCard(
      context: context,
      title: "SCHEDULE",
      imagePath: "assets/member-benefits.jpg",
      onTap: () {
        msg?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScheduleScreen(
              user: widget.user!.fbUser,
              locationName: "Bartlett",
            ),
          ),
        );
      },
    ),
    _buildHomeCard(
      context: context,
      title: "JITSU LABS",
      imagePath: "assets/styles.jpg",
    ),
    _buildHomeCard(
      context: context,
      title: "INSTRUCTORS",
      imagePath: "assets/about-us.jpg",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InstructorsScreen(),
          ),
        );
      },
    ),
    _buildHomeCard(
      context: context,
      title: "STYLES",
      imagePath: "assets/styles.jpg",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StylesScreen(),
          ),
        );
      },
    ),
    _buildProfileTools(context, widget),
  ];
}

Widget _buildHomeCard({
  required BuildContext context,
  required String title,
  required String imagePath,
  VoidCallback? onTap,
}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: buildBoxDecoration(Colors.black38, imagePath),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0XFFFFFFFF),
              fontSize: 32.0,
              fontWeight: FontWeight.normal,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _buildProfileTools(BuildContext context, HomeScreen widget) {
  return Container(
    padding: const EdgeInsets.fromLTRB(25, 25, 0, 0),
    child: Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  user: widget.user!.fbUser,
                ),
              ),
            );
          },
          child: _buildProfileOptionRow(
            icon: FontAwesomeIcons.user,
            label: "My Profile",
          ),
        ),
        SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => ViewScheduleScreen(
                  user: widget.user!.fbUser,
                  getAll: false,
                ),
              ),
            );
          },
          child: _buildProfileOptionRow(
            icon: FontAwesomeIcons.tasks,
            label: "My Classes",
          ),
        ),
        SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => AboutScreen(),
              ),
            );
          },
          child: _buildProfileOptionRow(
            icon: FontAwesomeIcons.infoCircle,
            label: "About",
          ),
        ),
      ],
    ),
  );
}

Widget _buildProfileOptionRow({
  required IconData icon,
  required String label,
}) {
  return Row(
    children: <Widget>[
      Icon(icon),
      SizedBox(width: 10),
      Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  );
}
