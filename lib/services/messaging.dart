import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class Messaging {
  static final StreamController<Map<String, dynamic>>
      _onMessageStreamController = StreamController.broadcast();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final Stream<Map<String, dynamic>> onFcmMessage =
      _onMessageStreamController.stream;

  static void setupFCMListeners() {
    if (Platform.isIOS) _requestIOSPermission();

    print("Registered FCM Listeners");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _onMessageStreamController.add(message.data);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _onMessageStreamController.add(message.data);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    _onMessageStreamController.add(message.data);
  }

  static void subscribeToTopic(String topic) {
    print("Subscribed to TOPIC: $topic");
    _firebaseMessaging.subscribeToTopic(topic);
  }

  static void cancelFcmMessaging() {
    _onMessageStreamController.close();
  }

  static Future<String?> getMessagingToken() async {
    return await _firebaseMessaging.getToken();
  }

  static String getAlert(Map<String, dynamic> message) {
    if (Platform.isIOS) {
      return message["aps"]["alert"]["body"] ?? "No message body";
    } else {
      return message["notification"]["body"] ?? "No message body";
    }
  }

  static void _requestIOSPermission() {
    _firebaseMessaging
        .requestPermission(
      sound: true,
      badge: true,
      alert: true,
    )
        .then((settings) {
      print("Settings registered: $settings");
    });
  }
}
