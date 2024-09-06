import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/admin/user-admin/user-admin-screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

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
        title: const Text("Admin"),
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
    ]));
  }

  List<Widget> _createAdminList(
      {required BuildContext context, required AdminScreen widget}) {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserAdminScreen(
                          userUid: '',
                          displayName: '',
                        )));
          },
          child: Container(
            color: Colors.grey,
            child: const Center(
              child: Text(
                "Users",
                style: TextStyle(
                    color: Color(0XFFFFFFFF),
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
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserAdminScreen(
                          userUid: '',
                          displayName: '',
                        )));
          },
          child: Container(
            color: Colors.grey,
            child: const Center(
              child: Text(
                "Events",
                style: TextStyle(
                    color: Color(0XFFFFFFFF),
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
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserAdminScreen(
                          userUid: '',
                          displayName: '',
                        )));
          },
          child: Container(
            color: Colors.grey,
            child: const Center(
              child: Text(
                "Instructors",
                style: TextStyle(
                    color: Color(0XFFFFFFFF),
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
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserAdminScreen(
                          userUid: '',
                          displayName: '',
                        )));
          },
          child: Container(
            color: Colors.grey,
            child: const Center(
              child: Text(
                "Manage Schedule",
                style: TextStyle(
                    color: Color(0XFFFFFFFF),
                    fontSize: 32.0,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Roboto'),
              ),
            ),
          ),
        ),
      )
    ];
  }
}
