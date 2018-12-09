import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/ScheduleMain/ByDate//index.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ScheduleMainScreen extends StatefulWidget {
  final String locationName;
  final FirebaseUser user;

  ScheduleMainScreen({this.locationName, this.user});

  @override
  _ScheduleMainScreenState createState() => _ScheduleMainScreenState();
}

class _ScheduleMainScreenState extends State<ScheduleMainScreen> {
  BuildContext context;

  @override
  void dispose() {
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
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
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
                        Tab(child: AutoSizeText(
                          "BY DATE",
                          style: TextStyle(fontSize: 10.0),
                        ),),
                        Tab(child: AutoSizeText(
                          "BY INSTRUCTOR",
                          style: TextStyle(fontSize: 10.0),
                        ),),
                        Tab(child: AutoSizeText(
                          "BY CLASS",
                          style: TextStyle(fontSize: 10.0),
                        ),),
                      ],
                    ),
                  ),
                  pinned: true,
                )
              ];
            },
            body: TabBarView(
              children: <Widget>[
                buildByDateTab(lastMidnight, widget),
                buildByInstructorTab(lastMidnight, widget),
                buildByClassTab(lastMidnight, widget)
              ],
            )
          ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
