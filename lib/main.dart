import 'package:agora_flutter_quickstart/src/pages/HomePage.dart';
import 'package:agora_flutter_quickstart/src/pages/WelcomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import './src/pages/index.dart';

void main() => runApp(
      MyApp(),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) {
          // return IndexPage();
          return snapshot.data == null
              ? WelcomePage()
              : HomePage(uid: snapshot.data.uid);
        },
      ),
    );
  }
}
