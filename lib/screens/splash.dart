import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vayu_agent/core/appcolors.dart';
import 'package:vayu_agent/screens/home.dart';
import 'package:vayu_agent/screens/login.dart';
import 'package:vayu_agent/widgets/vspace.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(
        Duration(
          seconds: 3,
        ), () async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      bool login = pref.getBool("islogin") ?? false;
      if (login) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(),
            ));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Login(),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Vayu Agent",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Vspace(32),
              Text(
                "Welcome to Vayu Family\n\n",
                style: TextStyle(fontSize: 18, color: AppColors.primaryGreen),
              ),
              // Text(
              //   "",
              //   style: TextStyle(fontSize: 18, color: AppColors.primaryGreen),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
