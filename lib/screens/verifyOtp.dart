import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vayu_agent/core/appcolors.dart';
import 'package:vayu_agent/screens/driverOnboard.dart';
import 'package:vayu_agent/widgets/vspace.dart';

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
      body: 
      
      
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Vspace(60),
            Text("Login",style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,

            ),),
            Vspace(24),
           TextField(  
            controller: otp,
            maxLength: 4,
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      labelText: 'OTP',  
                      hintText: 'Enter Your OTP',  
                    ),  
                     keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(4),
                                  FilteringTextInputFormatter.digitsOnly
                                ],autofocus: true  ,onChanged: (value) {
                                  if (value.length >= 4) {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                  }
                                },
                  ),  
                              Vspace(24),
    
          ],
        ),
      ),
      floatingActionButton:   FloatingActionButton(  
                  // textColor: Colors.white,  
                  // colo/r: AppColors.primaryGreen,  
                  backgroundColor: AppColors.primaryGreen,
                  child: Padding(

                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_forward,color: Colors.white,),
                  ),  
                  onPressed: (){ SharedPreferences.getInstance().then(
                (value) {
                  
                  value.setBool("isLogin", true);
                  value.setString("token", "value");
                },
                
              );
              Navigator.push(context, MaterialPageRoute(builder: (context) => DriverOnboard(),));},  
                )  ,
      // Column(
      //   children: [
      //     Text("Verify OTP"),
      //     TextField(controller: otp),
      //     FloatingActionButton(
      //       onPressed: () {
      //         SharedPreferences.getInstance().then(
      //           (value) {
      //             value.setBool("isLogin", true);
      //             value.setString("token", "value");
      //           },
      //         );
      //       },
      //       child: Text("Login"),
      //     )
        // ],
      // ),
    );
  }
}
