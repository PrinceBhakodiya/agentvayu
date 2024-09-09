import 'package:flutter/material.dart';
import 'package:vayu_agent/core/appcolors.dart';
import 'package:vayu_agent/screens/driverOnboard.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home"),
      backgroundColor: AppColors.primaryGreen,
       
      ),
body: Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DriverOnboard(),));
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen
        ,
        borderRadius: BorderRadius.all(Radius.circular(16))        ),
          child: Center(child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Driver Onboard",style: TextStyle(fontSize: 22,color: Colors.white),),
          )),
        ),
      ),
    )
  ],
),
    );
  }
}