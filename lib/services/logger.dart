import 'package:meta/meta.dart';

class Logger {
  static void log(String tag, {required String message}) {
    print("[$tag] $message");
  }
}
