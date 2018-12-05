import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:memphisbjj/theme/style.dart';
import 'package:memphisbjj/screens/ScheduleMain/index.dart';
import 'package:memphisbjj/screens/Login/index.dart';
import 'package:memphisbjj/utils/UserItem.dart';
import 'package:memphisbjj/screens/Admin/index.dart';

class HomeScreen extends StatefulWidget {
  final UserItem user;
  final FirebaseUser anonymousUser;

  const HomeScreen({Key key, this.user, this.anonymousUser}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    List<Widget> list;
    if (widget.anonymousUser != null && widget.anonymousUser.isAnonymous) {
      list = _createMemberList(context: context, widget: widget);
    } else if (widget.user != null && widget.user.roles.admin) {
      list = _createAdminList(context: context, widget: widget);
    } else if (widget.user != null && widget.user.roles.subscriber) {
      list = _createMemberList(context: context, widget: widget);
    }

    return Scaffold(
      floatingActionButton: widget.anonymousUser != null
          ? Container(
              height: 85.0,
              width: 85.0,
              child: FloatingActionButton(
                child: Text("SIGN UP"),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen())),
              ))
          : Container(width: 0.0, height: 0.0),
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          title: Text("Memphis Judo & Jiu-Jitsu"),
          expandedHeight: 200.0,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              "assets/app-drawer-main.jpg",
              fit: BoxFit.cover,
            ),
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 200.0,
          delegate: SliverChildListDelegate(list),
        ),
      ]),
    );
  }
}

List<Widget> _createAdminList({BuildContext context, HomeScreen widget}) {
  return [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => AdminScreen()));
        },
        child: Container(
          color: Colors.white,
          child: Center(
            child: Text(
              "Admin",
              style: const TextStyle(
                  color: const Color(0XFF000000),
                  fontSize: 32.0,
                  fontFamily: 'WorkSansMedium'),
            ),
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ScheduleMainScreen(
                        locationName: "Bartlett",
                        user: widget.user.fbUser,
                      )));
        },
        child: Container(
          decoration:
              buildBoxDecoration(Colors.black87, "assets/member-benefits.jpg"),
          child: Center(
            child: Text(
              "SCHEDULE",
              style: const TextStyle(
                  color: const Color(0XFFFFFFFF),
                  fontSize: 32.0,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto'),
            ),
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: buildBoxDecoration(Colors.brown, "assets/about-us.jpg"),
        child: Center(
          child: Text(
            "SOCIAL MEDIA",
            style: const TextStyle(
                color: const Color(0XFFFFFFFF),
                fontSize: 32.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto'),
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: buildBoxDecoration(Colors.deepPurple, "assets/styles.jpg"),
        child: Center(
          child: Text(
            "STYLES",
            style: const TextStyle(
                color: const Color(0XFFFFFFFF),
                fontSize: 32.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto'),
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration:
            buildBoxDecoration(Colors.blueAccent, "assets/about-us.jpg"),
        child: Center(
          child: Text(
            "INSTRUCTORS",
            style: const TextStyle(
                color: const Color(0XFFFFFFFF),
                fontSize: 32.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto'),
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: buildBoxDecoration(Colors.white70, "assets/about-us.jpg"),
        child: Center(
          child: Text(
            "ABOUT US",
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 32.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto'),
          ),
        ),
      ),
    ),
  ];
}

List<Widget> _createMemberList({BuildContext context, HomeScreen widget}) {
  return [
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ScheduleMainScreen(
                        locationName: "Bartlett",
                        user: widget.user.fbUser,
                      )));
        },
        child: Container(
          decoration:
              buildBoxDecoration(Colors.black87, "assets/member-benefits.jpg"),
          child: Center(
            child: Text(
              "SCHEDULE",
              style: const TextStyle(
                  color: const Color(0XFFFFFFFF),
                  fontSize: 32.0,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto'),
            ),
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: buildBoxDecoration(Colors.brown, "assets/about-us.jpg"),
        child: Center(
          child: Text(
            "SOCIAL MEDIA",
            style: const TextStyle(
                color: const Color(0XFFFFFFFF),
                fontSize: 32.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto'),
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: buildBoxDecoration(Colors.deepPurple, "assets/styles.jpg"),
        child: Center(
          child: Text(
            "STYLES",
            style: const TextStyle(
                color: const Color(0XFFFFFFFF),
                fontSize: 32.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto'),
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration:
            buildBoxDecoration(Colors.blueAccent, "assets/about-us.jpg"),
        child: Center(
          child: Text(
            "INSTRUCTORS",
            style: const TextStyle(
                color: const Color(0XFFFFFFFF),
                fontSize: 32.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto'),
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: buildBoxDecoration(Colors.white70, "assets/about-us.jpg"),
        child: Center(
          child: Text(
            "ABOUT US",
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 32.0,
                fontWeight: FontWeight.normal,
                fontFamily: 'Roboto'),
          ),
        ),
      ),
    ),
  ];
}
