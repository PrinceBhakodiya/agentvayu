import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController number = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar("Login"),
      body: Column(
        children: [
          Text("Login"),
          TextField(controller: number),
          FloatingActionButton(
            onPressed: () {},
            child: Text("Next"),
          )
        ],
      ),
    );
  }
}
