import 'package:flutter/material.dart';
import 'package:memphisbjj/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:memphisbjj/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const App());
}
