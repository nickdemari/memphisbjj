import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/schedule-feature/class-tab-builder/class-tab-builder.dart';
import 'package:memphisbjj/screens/schedule-feature/date-tab-builder/date-tab-builder.dart';
import 'package:memphisbjj/screens/schedule-feature/instructor-tab-builder/instructor-tab-builder.dart';
import 'package:memphisbjj/services/messaging.dart';

class ScheduleScreen extends StatefulWidget {
  final String locationName;
  final User user;

  ScheduleScreen({required this.locationName, required this.user});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  StreamSubscription<Map<String, dynamic>>? _msgStream;
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _subscribeToFCM();
  }

  @override
  void dispose() {
    _msgStream?.cancel(); // Properly cancel the subscription
    super.dispose();
  }

  void _subscribeToFCM() {
    Messaging.subscribeToTopic("testing");
    _msgStream = Messaging.onFcmMessage.listen((data) {
      print("FCM TRIGGERED in schedule main");
      var alert = Messaging.getAlert(data);
      _showSnackBar(alert, Colors.deepOrange);
    });
  }

  void _showSnackBar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final lastMidnight = DateTime(now.year, now.month, now.day);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _globalKey,
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 125.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "${widget.locationName} Schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    ),
                  ),
                  background: Image.asset(
                    "assets/member-benefits.jpg",
                    fit: BoxFit.cover,
                    color: Color(0xff3e4b60),
                    colorBlendMode: BlendMode.hardLight,
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorColor: Colors.black,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white30,
                    tabs: [
                      Tab(
                          child: AutoSizeText("BY DATE",
                              style: TextStyle(fontSize: 10.0))),
                      Tab(
                          child: AutoSizeText("BY INSTRUCTOR",
                              style: TextStyle(fontSize: 10.0))),
                      Tab(
                          child: AutoSizeText("BY CLASS",
                              style: TextStyle(fontSize: 10.0))),
                    ],
                  ),
                ),
                pinned: true,
              )
            ];
          },
          body: TabBarView(
            children: <Widget>[
              DateTabBuilder(
                lastMidnight: lastMidnight,
                widget: widget,
              ),
              InstructorTabBuilder(
                lastMidnight: lastMidnight,
                widget: widget,
              ),
              ClassTabBuilder(
                lastMidnight: lastMidnight,
                widget: widget,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
