import 'package:meta/meta.dart';

class Logger {
  static void log(String tag, {@required String message}) {
    assert(tag != null);
    print("[$tag] $message");
  }
}