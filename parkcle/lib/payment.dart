import 'package:flutter/material.dart';

import 'main.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                children: [
                Image.asset('assets/logo.png', height: 50),
                const  GradientText(
                  'arCle',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 247, 255, 5),
                      Color.fromARGB(222, 8, 255, 24),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
                const Text("Payment Page"),
            ],
          ),
        ),
    );
  }
}
