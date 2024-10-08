import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vayu_agent/core/appcolors.dart';
import 'package:vayu_agent/screens/driverOnboard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
String name="";
void setName ()async{
 SharedPreferences pref = await SharedPreferences.getInstance();
setState(() {
name = pref.getString("name") ?? "";
  
});
}
@override
  void initState() {
    setName();
    // TODO: implement initState
    super.initState();
       
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Vayu Agents ",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
             Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Hello $name ",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriverOnboard(),
                    ));
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.drive_eta_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                      Text(
                        "Driver Onboard",
                        style: TextStyle(fontSize: 22, color: Colors.white),
                      ),
                    ],
                  ),
                )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
