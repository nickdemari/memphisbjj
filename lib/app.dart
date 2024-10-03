import 'package:flutter/material.dart';
import 'package:memphisbjj/screens/splash-screen/splash-screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreenPage(key: Key('SplashScreen'), seconds: 2),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFe1e4e5),
        primaryColor: const Color(0xFF1a256f),
        appBarTheme: const AppBarTheme(
          color: Color.fromARGB(255, 26, 26, 28),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
    );
  }
}
