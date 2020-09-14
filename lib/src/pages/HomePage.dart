import 'dart:convert';

import 'package:agora_flutter_quickstart/Constants.dart';
import 'package:agora_flutter_quickstart/src/Widget/UserCardWidget.dart';
import 'package:agora_flutter_quickstart/src/pages/call.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  final String uid;

  HomePage({this.uid});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String serverToken =
      'AAAAbbuWh8c:APA91bGgNLx6SBtpR32P8QFrZxEfHFjJPlGv7rKXBUVlKaGP2v2PVRMnHrHpa0Q3XBKS87FlGHsLhgF0pwTb9tP2Rvg_1qTdM_d1ZsC4Kl3g6vAL1LHeQtcVqPa-TiQydU4_8zhe8Gbg';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  @override
  void initState() {
    super.initState();
    firebaseMessaging.configure(
      onMessage: (message) async {
        print(message);
        print("************************");
        await _handleCameraAndMic();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallPage(
              channelName: message['data']['channel'],
              role: ClientRole.Audience,
            ),
          ),
        );
      },
      onLaunch: (message) async {
        await _handleCameraAndMic();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallPage(
              channelName: message['data']['channel'],
              role: ClientRole.Audience,
            ),
          ),
        );
      },
      onResume: (message) async {
        await _handleCameraAndMic();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallPage(
              channelName: message['data']['channel'],
              role: ClientRole.Audience,
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  sendAndRetrieveMessage(to) async {
    final uuid = Uuid().v4();
    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );

    final res = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'this is a body',
            'title': 'this is a title'
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'channel': uuid,
          },
          'to': to,
        },
      ),
    );
    await _handleCameraAndMic();
    print(uuid);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CallPage(
                  channelName: uuid,
                  role: ClientRole.Broadcaster,
                )));
    print(res.statusCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: Text('Video Call Page'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
          onPressed: null,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
            ),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: FutureBuilder(
        future: Firestore.instance.collection('users').getDocuments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SpinKitDoubleBounce(color: kPrimaryColor);
          }

          return ListView.builder(
            itemCount: snapshot.data.documents.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SizedBox(height: 40);
              }
              if (widget.uid == snapshot.data.documents[index - 1]['uid']) {
                return Container();
              }
              return GestureDetector(
                  onTap: () => sendAndRetrieveMessage(
                      snapshot.data.documents[index - 1]['token']),
                  child:
                      UserCardWidget(json: snapshot.data.documents[index - 1]));
            },
          );
        },
      ),
    );
  }
}
