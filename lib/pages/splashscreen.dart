import 'dart:async';

import 'package:flutter/material.dart';
import 'package:recipewise/auth/mainpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration(seconds: 3),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC2D076),
      body: Center(
        child: Container(
          width: 400,
          height: 400,
          child: Image.asset('assets/RecipeWise_removebg.png'),
        ),
      ),
    );
  }
}
