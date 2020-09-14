import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_overlay/loading_overlay.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  String username = '';
  bool _isLoading = false;

  hanldeSigninAnynomous() async {
    setState(() {
      _isLoading = true;
    });
    final result = await FirebaseAuth.instance.signInAnonymously();

    await Firestore.instance
        .collection('users')
        .document(result.user.uid)
        .setData({
      'token': await FirebaseMessaging().getToken(),
      'username': username,
      'timestamp': Timestamp.now(),
      'uid': result.user.uid,
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      color: Colors.black,
      progressIndicator:
          SpinKitPouringHourglass(color: Colors.deepPurpleAccent),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Image.asset(
                'images/welcome.png',
                height: 300,
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello There!',
                      style: TextStyle(
                        color: Color(0xFF00AEFF),
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      'Please enter your name and get connected with your family,friends & many more',
                      style: TextStyle(
                        color: Color(0xFF00AEFF).withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      onChanged: (value) {
                        username = value;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.redAccent)),
                        hintText: 'Enter your fullname',
                        helperText: 'Must contain atleast 3 chars',
                        labelText: 'Full Name',
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => hanldeSigninAnynomous(),
                child: Container(
                  height: 60,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Color(0xFF00AEFF),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Center(
                    child: Text(
                      'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
