import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/SplashScreen/index.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreenPage(key: Key("SplashScreen"), seconds: 2),
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFe1e4e5),
        primaryColor: Color(0xFF1a256f),
        appBarTheme: AppBarTheme(
          color: Color.fromARGB(255, 26, 26, 28),
        ),
      ),
    );
  }
}
