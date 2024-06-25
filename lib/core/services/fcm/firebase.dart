import 'dart:convert';
import 'dart:math';

import 'package:CeeRoom/core/controllers/chat/chat_controller.dart';
import 'package:CeeRoom/core/models/chat_model.dart';
import 'package:CeeRoom/core/models/contact_model.dart';
import 'package:CeeRoom/utils/incoming_call.dart';
import 'package:CeeRoom/utils/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// TODO => Kerloper check life cycle of this parameter
/// this param for ???
bool callShowed = false;

Future<void> _getCustomInformation(RemoteMessage rm, {bool fromBackground = false}) async {
  Map<String, dynamic> data = rm.data;
  // index-call-1
  // Kerloper => start receive notification for call
  if (data['custom_information'] != null) {
    data = json.decode(data["custom_information"]);
    if (data.isNotEmpty) {
      if (data.containsKey('call_id')) {
        showIncomingCall(
          data['call_id'],
          ContactModel.fromJson(data['caller']),
          data['call_type'],
          data['is_group_call'],
        );
        // Kerloper => notification is a chat alert
      } else if (data.containsKey('conversation_id')) {
        Get.put(ChatController()).getChats(clear: false);
        if (fromBackground) {
          Get.toNamed(
            Routes.singleChat,
            arguments: {
              'chat': ChatModel(
                conversationId: data['conversation_id'],
                profiles: getAllContacts(
                  data['profiles'],
                ),
              ),
              'contact': null
            },
          );
        }
      }
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage rm) async {
  debugPrint("Handling a background message: ${rm.messageId}");
  await Firebase.initializeApp();
  // index-notification => when => [app is minimize]
  _getCustomInformation(rm);
}

class AppFirebase {
  late final FirebaseMessaging _firebaseMessaging;

  Future<void> initFirebase() async {
    await Firebase.initializeApp();
    _firebaseMessaging = FirebaseMessaging.instance;
    _firebasePermission();
    _firebaseCloudMessagingListeners();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
        'Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}',
      );
      // index-notification => when => [in app]
      await Firebase.initializeApp();
      _getCustomInformation(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      // Obtain shared preferences.
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('from_notification', true);
      await Firebase.initializeApp();
      _getCustomInformation(message, fromBackground: true);
    });

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    _firebaseMessaging.getToken().then((String? token) async {
      assert(token != null);
      await _subscribeToTopic();
    });
  }

  Future<void> _firebasePermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
  }

  void _firebaseCloudMessagingListeners() {
    _firebaseMessaging.getToken().then((token) {
      debugPrint(token);
    });
  }

  Future _subscribeToTopic() async {
    try {
      await _firebaseMessaging.subscribeToTopic('global');
    } catch (e) {
      await Future.delayed(Duration(seconds: 5 + Random().nextInt(25)));
      await _subscribeToTopic();
    }
  }
}
