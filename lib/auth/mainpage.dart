import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipewise/auth/authpage.dart';
import 'package:recipewise/components/bottom_navi.dart';
import 'package:recipewise/pages/homepage.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return bottomNavi();
        } else {
          return AuthPage();
        }
      },
    ));
  }
}
