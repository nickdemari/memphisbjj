import 'package:flutter/material.dart';
import 'package:memphisbjj/utils/ListItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memphisbjj/screens/Admin/UserAdmin/index.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    var list = _createAdminList(context: context, widget: widget);

    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverAppBar(
          title: Text("Admin"),
          expandedHeight: 200.0,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              "assets/app-drawer-main.jpg",
              fit: BoxFit.cover,
            ),
          ),
        ),
        SliverFixedExtentList(
          itemExtent: 100.0,
          delegate: SliverChildListDelegate(list),
        ),
      ])
    );
  }

  List<Widget> _createAdminList({BuildContext context, AdminScreen widget}) {
    return
      [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserAdminScreen()));
            },
            child: Container(
              color: Colors.grey,
              child: Center(
                child: Text(
                  "Users",
                  style: const TextStyle(color: const Color(0XFFFFFFFF), fontSize: 32.0, fontWeight: FontWeight.normal, fontFamily: 'Roboto'),
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
                      builder: (context) => UserAdminScreen()));
            },
            child: Container(
              color: Colors.grey,
              child: Center(
                child: Text(
                  "Events",
                  style: const TextStyle(color: const Color(0XFFFFFFFF), fontSize: 32.0, fontWeight: FontWeight.normal, fontFamily: 'Roboto'),
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
                      builder: (context) => UserAdminScreen()));
            },
            child: Container(
              color: Colors.grey,
              child: Center(
                child: Text(
                  "Instructors",
                  style: const TextStyle(color: const Color(0XFFFFFFFF), fontSize: 32.0, fontWeight: FontWeight.normal, fontFamily: 'Roboto'),
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
                      builder: (context) => UserAdminScreen()));
            },
            child: Container(
              color: Colors.grey,
              child: Center(
                child: Text(
                  "Manage Schedule",
                  style: const TextStyle(color: const Color(0XFFFFFFFF), fontSize: 32.0, fontWeight: FontWeight.normal, fontFamily: 'Roboto'),
                ),
              ),
            ),
          ),
        )
      ];
  }
}
