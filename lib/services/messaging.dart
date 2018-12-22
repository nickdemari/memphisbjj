import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

class Messaging {
  static StreamController<Map<String, dynamic>> _onMessageStreamController = StreamController.broadcast();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static final Stream<Map<String, dynamic>> onFcmMessage =_onMessageStreamController.stream;

  static setupFCMListeners() {
    if (Platform.isIOS) _iOS_Permission();

    print("Registered FCM Listeners");
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _onMessageStreamController.add(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        _onMessageStreamController.add(message);
      },
      onResume: (Map<String, dynamic> message) async {
        _onMessageStreamController.add(message);
      },
    );
  }

  static subscribeToTopic(String topic) {
    print("Subscribed to TOPIC: $topic");
    _firebaseMessaging.subscribeToTopic(topic);
  }

  static cancelFcmMessaging() {
    _onMessageStreamController.close();
  }

  static Future<String> getMessagingToken() async {
    return await _firebaseMessaging.getToken();
  }

  static String getAlert(Map<String, dynamic> message) {
    return Platform.isIOS ? message["aps"]["alert"]["body"] : message["notification"]["body"];
  }

  static void _iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings)
    {
      print("Settings registered: $settings");
    });
  }
}