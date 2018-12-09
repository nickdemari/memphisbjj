import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/SplashScreen/index.dart';

class Routes {
  Routes() {
    /*var routes = <String, WidgetBuilder>{
      "/HomePage": (BuildContext context) => new HomeScreen(),
      "/LoginPage": (BuildContext context) => new LoginScreen(),
      "/Schedule_Main": (BuildContext context) => new ScheduleMainScreen(),
      "/LocationsPage": (BuildContext context) => new LocationsScreen()
    };*/

    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
          home: SplashScreenPage(
            seconds: 2
          ),
          theme: ThemeData(
            scaffoldBackgroundColor: Color(0xFFe1e4e5),
            primaryColor: Color(0xFF1a256f),
          )
      ),
    );
  }
}
