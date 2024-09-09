import 'package:flutter/material.dart';

class DriverOnboard extends StatefulWidget {
  const DriverOnboard({super.key});

  @override
  State<DriverOnboard> createState() => _DriverOnboardState();
}

class _DriverOnboardState extends State<DriverOnboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Driver Onboard"),
        ],
      ),
    );
  }
}
