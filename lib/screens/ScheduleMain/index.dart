import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/ScheduleMain/ByClass/index.dart';
import 'package:memphisbjj/screens/ScheduleMain/ByDate//index.dart';
import 'package:memphisbjj/screens/ScheduleMain/ByInstructor/index.dart';
import 'package:memphisbjj/services/messaging.dart';

class ScheduleMainScreen extends StatefulWidget {
  final String locationName;
  final FirebaseUser user;

  ScheduleMainScreen({this.locationName, this.user});

  @override
  _ScheduleMainScreenState createState() => _ScheduleMainScreenState();
}

class _ScheduleMainScreenState extends State<ScheduleMainScreen> {
  BuildContext context;
  StreamSubscription<Map<String, dynamic>> _msgStream;
  GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Messaging.subscribeToTopic("testing");
    _msgStream = Messaging.onFcmMessage.listen((data) {
      print("FCM TRIGGERED schedule main");
      var alert = Messaging.getAlert(data);
      var snackBar = SnackBar(
        content: Text(alert),
        backgroundColor: Colors.deepOrange,
      );
      _globalKey.currentState.showSnackBar(snackBar);

      _msgStream.cancel();
    });
    super.initState();
  }

  @override
  void dispose() {
    print("SCHEDULE MAIN DISPOSED");

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;

    final now = DateTime.now();
    final lastMidnight = new DateTime(now.year, now.month, now.day);

    return Container(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: _globalKey,
          body: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                innerBoxIsScrolled = true;
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 125.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text("${widget.locationName} Schedule",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          )),
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
                            child: AutoSizeText(
                              "BY DATE",
                              style: TextStyle(fontSize: 10.0),
                            ),
                          ),
                          Tab(
                            child: AutoSizeText(
                              "BY INSTRUCTOR",
                              style: TextStyle(fontSize: 10.0),
                            ),
                          ),
                          Tab(
                            child: AutoSizeText(
                              "BY CLASS",
                              style: TextStyle(fontSize: 10.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    pinned: true,
                  )
                ];
              },
              body: TabBarView(
                children: <Widget>[
                  buildByDateTab(lastMidnight, widget, _msgStream),
                  buildByInstructorTab(lastMidnight, widget, _msgStream),
                  buildByClassTab(lastMidnight, widget, _msgStream),
                ],
              )),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Material(
      color: Colors.black,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
