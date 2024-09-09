import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vayu_agent/core/Appconstant.dart';
import 'package:vayu_agent/core/appcolors.dart';
import 'package:vayu_agent/core/customcontainer.dart';
import 'package:vayu_agent/core/text.dart';
import 'package:vayu_agent/core/textfield.dart';
import 'package:vayu_agent/screens/verifyOtp.dart';
import 'package:vayu_agent/widgets/hspace.dart';
import 'package:vayu_agent/widgets/vspace.dart';

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
      body: Padding(
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
            controller: number,
                    decoration: InputDecoration(  
                      border: OutlineInputBorder(),  
                      labelText: 'Phone Number',  
                      hintText: 'Enter Your Phone Number',  
                    ),  
                     keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10),
                                  FilteringTextInputFormatter.digitsOnly
                                ],autofocus: true  ,onChanged: (value) {
                                  if (value.length >= 10) {
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
                  onPressed: ()async{
                    
                    Dio dio=Dio();
                    await dio.post("${AppConstants.baseUrl}/agentLogin",data: {
                        "phone":number.text
                    }).then(
                      (value) {
                        print(value);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => VerifyOtp(number: number.text,),));

                      }
                    );}
      )
        );
  }
}
