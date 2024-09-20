import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memphisbjj/screens/about/about-screen.dart';
import 'package:memphisbjj/screens/admin/admin-screen.dart';
import 'package:memphisbjj/screens/instructors/instructers-screen.dart';
import 'package:memphisbjj/screens/onboarding/login/view/login-screen.dart';
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
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Messaging.subscribeToTopic('testing');
    _msgStream = Messaging.onFcmMessage.listen((data) {
      var alert = Messaging.getAlert(data);
      Messaging.cancelFcmMessaging();
      var snackBar = SnackBar(
        content: Text(alert),
        backgroundColor: Colors.deepOrange,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }

  @override
  void dispose() {
    _msgStream?.cancel();
    super.dispose();
  }

  List<Widget> _getHomeScreenList() {
    if (widget.anonymousUser != null && widget.anonymousUser!.isAnonymous) {
      return _createMemberList();
    } else if (widget.user != null && widget.user!.roles.admin) {
      return _createAdminList();
    } else if (widget.user != null && widget.user!.roles.subscriber) {
      return _createMemberList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final list = _getHomeScreenList();

    return SafeArea(
      maintainBottomViewPadding: false,
      child: Scaffold(
        key: _globalKey,
        floatingActionButton: widget.anonymousUser != null
            ? SizedBox(
                height: 85.0,
                width: 85.0,
                child: FloatingActionButton(
                  child: const Text('SIGN UP'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        body: CustomScrollView(
          slivers: <Widget>[
            // Add an indent into the app bar
            // Custom SliverAppBar with logo and title and a background image
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.65,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/app-drawer-main.jpg'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(16.0),
                          bottomRight: Radius.circular(16.0),
                        ),
                      ),
                    ),
                    // large font of Memphis Judo & Jiu-Jitsu
                    Positioned(
                      top: 60.0,
                      left: 16.0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          'Memphis Judo & Jiu-Jitsu',
                          style: GoogleFonts.anton(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 74,
                            color: Colors.white54,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                    // the word 'BARTLETT' ON THE BOTTOM LEFT
                    Positioned(
                      bottom: 16.0,
                      left: 16.0,
                      child: Text(
                        'BARTLETT',
                        style: GoogleFonts.anton(
                          textStyle: Theme.of(context).textTheme.displayLarge,
                          fontSize: 32,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    // up carat icon at the bottom of the flexible space bar
                    Positioned(
                      right: 16.0,
                      bottom: 16.0,
                      child: IconButton(
                        onPressed: () {
                          // using a scroll controller animate to the top of the list by setting the
                        },
                        icon: const Icon(
                          Icons.arrow_upward,
                          color: Color.fromARGB(128, 255, 255, 255),
                          size: 32.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return list[index];
                  },
                  childCount: list.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _createAdminList() {
    return [
      _buildHomeCard(
        title: 'SCHEDULE',
        imagePath: 'assets/member-benefits.jpg',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleScreen(
                user: widget.user!.fbUser,
                locationName: 'Bartlett',
              ),
            ),
          );
        },
      ),
      _buildHomeCard(
        title: 'INSTRUCTORS',
        imagePath: 'assets/about-us.jpg',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InstructorsScreen(),
            ),
          );
        },
      ),
      _buildHomeCard(
        title: 'STYLES',
        imagePath: 'assets/styles.jpg',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StylesScreen(),
            ),
          );
        },
      ),
      _buildHomeCard(title: 'EVENTS'),
      const SizedBox(height: 16),
      _buildProfileTools(withAdmin: true),
    ];
  }

  List<Widget> _createMemberList() {
    return [
      _buildHomeCard(
        title: 'SCHEDULE',
        imagePath: 'assets/member-benefits.jpg',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleScreen(
                user: widget.user!.fbUser,
                locationName: 'Bartlett',
              ),
            ),
          );
        },
      ),
      _buildHomeCard(
        title: 'INSTRUCTORS',
        imagePath: 'assets/about-us.jpg',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InstructorsScreen(),
            ),
          );
        },
      ),
      _buildHomeCard(
        title: 'STYLES',
        imagePath: 'assets/styles.jpg',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StylesScreen(),
            ),
          );
        },
      ),
      _buildHomeCard(title: 'EVENTS'),
      const SizedBox(height: 16),
      _buildProfileTools(),
    ];
  }

  Widget _buildHomeCard({
    required String title,
    String? imagePath,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120.0,
          padding: const EdgeInsets.all(16.0),
          decoration: imagePath != null
              ? buildBoxDecoration(Colors.black38, imagePath)
              : const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  // standard box shadow
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16.0,
                      spreadRadius: 4.0,
                      offset: Offset(0.0, 8.0),
                    ),
                  ],
                ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title,
              style: TextStyle(
                color: imagePath != null ? Colors.white : Colors.black87,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTools({bool withAdmin = false}) {
    return Column(
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
            label: 'My Profile',
          ),
        ),
        const SizedBox(height: 15),
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
            icon: FontAwesomeIcons.listCheck,
            label: 'My Classes',
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => const AboutScreen(),
              ),
            );
          },
          child: _buildProfileOptionRow(
            icon: FontAwesomeIcons.circleInfo,
            label: 'About',
          ),
        ),
        if (withAdmin) ...[
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const AdminScreen(),
                ),
              );
            },
            child: _buildProfileOptionRow(
              icon: FontAwesomeIcons.userShield,
              label: 'Admin',
            ),
          ),
        ],
        const SizedBox(height: 32),
        const Text(
          'Made with ❤️ by Memphis Judo & Jiu-Jitsu',
          style: TextStyle(
            color: Colors.black,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptionRow({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 16,
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
