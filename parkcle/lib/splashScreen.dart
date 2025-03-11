import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parkcle/main.dart';
import 'package:parkcle/signUp.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  // Suggested code may be subject to a license. Learn more: ~LicenseLog:977331873.
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 4),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Signup()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 50),
              const GradientText(
                'arCle',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                gradient: LinearGradient(colors: [
                  Color.fromARGB(255, 247, 255, 5),
                  Color.fromARGB(222, 8, 255, 24),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
