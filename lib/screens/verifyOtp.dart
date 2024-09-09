import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyOtp extends StatefulWidget {
  final String number;
  const VerifyOtp({super.key, required this.number});

  @override
  State<VerifyOtp> createState() => _LoginState();
}

class _LoginState extends State<VerifyOtp> {
  TextEditingController otp = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar("Login"),
      body: Column(
        children: [
          Text("Verify OTP"),
          TextField(controller: otp),
          FloatingActionButton(
            onPressed: () {
              SharedPreferences.getInstance().then(
                (value) {
                  value.setBool("isLogin", true);
                  value.setString("token", "value");
                },
              );
            },
            child: Text("Login"),
          )
        ],
      ),
    );
  }
}
