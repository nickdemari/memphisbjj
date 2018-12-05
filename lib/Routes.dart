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
          home: SplashScreenPage(
            seconds: 2
          ),
          theme: ThemeData.light()
      ),
    );
  }
}
