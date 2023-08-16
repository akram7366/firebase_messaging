import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final item = Item.fromJson(message.data);
  if (item.title == null || item.body == null) return;
  createNotification(item);
  data(item: item);
}

Future<void> firebase() async {
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.subscribeToTopic('all');
}

void onMessageListen(void Function(Item item)  onMessage) {
  FirebaseMessaging.onMessage.listen((message) {
    final item = Item.fromJson(message.data);
    if (item.title == null || item.body == null) return;
    createNotification(item);
    onMessage(item);
  });
}

final dio = Dio();
Future<void> sendNotification(String title, String body) async {
  try {
    await dio.post('https://fcm.googleapis.com/fcm/send',
        data: jsonEncode({
          'to': "/topics/all",
          'priority': 'high',
          'data': {
            'body': body,
            'title': title,
          },
        }),
        options: Options(
          headers: {
            'Authorization':
            'key=AAAAvGWnd9k:APA91bEWYORmj16e_SbEr_Z8ylP0JBLEJbGM9sYv43-1NnfjG4ZvsPvuJiLkqZVyvNbwCyXmt6mSALF25nXECfH7ZHvUo64PNRGyCFUlBKnf2BeDgPxWQHZkeX3vLPMqlbHwij3h_bZy',
            'Content-Type': 'application/json'
          },
        ));
  } catch (_) {}
}

void createNotification(Item item) async {
  FlutterLocalNotificationsPlugin().show(
    item.body.hashCode,
    item.title,
    item.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'notifications',
        'الأشعارات',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'book',
        largeIcon: DrawableResourceAndroidBitmap('mipmap/ic_launcher')
      ),
    ),
  );
}

Future<List<Item>> data({Item? item}) async {
  var list = <Item>[];
  try {
    final shared = await SharedPreferences.getInstance();
    final json = shared.getString('list');
    if (json != null) {
      list = (jsonDecode(json) as List).map((e) => Item.fromJson(e)).toList();
    }
    if (item != null) {
      list.insert(0, item);
      await shared.setString('list', jsonEncode(list));
    }
  } catch (_) {}

  return list;
}

class Item {
  final String? title, body;

  Item(this.title, this.body);

  factory Item.fromJson(item) => Item(item['title'], item['body']);

  Map toJson() => {
        'title': title,
        'body': body,
      };
}
