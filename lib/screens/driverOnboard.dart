import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tab_container/tab_container.dart';
import 'package:vayu_agent/core/Appconstant.dart';
import 'package:vayu_agent/core/Imagepicker.dart';
import 'package:vayu_agent/core/appcolors.dart';
import 'package:vayu_agent/core/customcontainer.dart';
import 'package:vayu_agent/core/text.dart';
import 'package:vayu_agent/core/uti.dart';
import 'package:vayu_agent/widgets/hspace.dart';
import 'package:vayu_agent/widgets/vspace.dart';

enum VehicleDetailType { auto, sedan, hatchback, suv }

class DriverOnboard extends StatefulWidget {
  const DriverOnboard({super.key});

  @override
  State<DriverOnboard> createState() => _DriverOnboardState();
}

class _DriverOnboardState extends State<DriverOnboard>  with SingleTickerProviderStateMixin{
  var vehiclenamemodel;
  bool _loading = false;
  String type = "";
  String dropdownvalue = 'Sedan';
  VehicleDetailType? _vehicleDetailType;
  late final TabController _controller;

  TextEditingController vehicleNumber = TextEditingController();
  TextEditingController datePickerController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileNumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController upiID = TextEditingController();
  TextEditingController licenseno = TextEditingController();

  ImagePickerUtil driverPhoto = ImagePickerUtil();
  ImagePickerUtil drivingLicenceFront = ImagePickerUtil();
  ImagePickerUtil drivingLicenceBack = ImagePickerUtil();
  ImagePickerUtil rCBook = ImagePickerUtil();
int selectedDlindex=0;
  String? selectedDropdownValue;

  String name = "";
  // final List<String> dropdownOptions = ['@ybl', '@axl', '@ibl', '@paytm','@upi'];
  Dio dio = Dio();
  FocusNode myFocusNode = FocusNode();
  bool dlverified = false;
  bool rcverified = false;

  FocusNode lfocus = FocusNode();
  FocusNode dobfocus = FocusNode();
  Future<void> verifyRC() async {
    // Define your API endpoint
    const String apiUrl = '${AppConstants.ONDCbaseUrl}/rcVerify';

    // Define your request body, if needed
    try {
      var body = {
        "vehicleNumber": vehicleNumber.text,
        // "phone": ""
        "phone": mobileNumber.text
      };
      print(body);
      final response = await dio.post(
        apiUrl,
        data: body,
      );

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the response
        final Map<String, dynamic> responseData = response.data;
        print("response data is $responseData");
        print(
            "makermodelofcar${responseData["driverDataWithRc"]["vehicleMakerModel"]}");
        if (responseData["message"] == "RC Verified Successfully") {
          setState(() {
            rcverified = true;
            _loading = false;
            vehiclenamemodel =
                responseData["driverDataWithRc"]["vehicleMakerModel"];
          });
        } else {
          setState(() {
            rcverified = false;
            // name=responseData["driverData"]["name"];
          });
        }
        // Store the response data in variables or state
        // For example, you can store it in a variable in the stateful widget
        // or update the UI with the response data
        print(responseData); // print the response for demonstration
      } else {
        // Handle any errors or exceptions
        print('Request failed with status: ${response.statusCode}');
      }
    } on DioError catch (error) {
      setState(() {
        rcverified = false;
        _loading = false;
        // name=responseData["driverData"]["name"];
      });
      print("debug 3");

      print(error.response!.data);
      print("error == $error");
      Fluttertoast.showToast(
          msg: "RC is not found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (exception) {
      print("debug 4");
      return;
    }
  }

  Future<void> verifyDl(String licenseNumber) async {
    // Define your API endpoint
    print(datePickerController.text);
    // datePickerController.text = DateFormat('yyyy-MM-dd').format(DateTime.parse(datePickerController.text));
    DateTime parsedDate =
        DateFormat('dd-MM-yyyy').parse(datePickerController.text);

    // Format the parsed date to yyyy-MM-dd
    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    print(formattedDate);
    const String apiUrl = '${AppConstants.ONDCbaseUrl}/dlVerify';
    try {
      // Define your request body, if needed
      var body = {
        "licenseNumber": licenseNumber,
        "dob": formattedDate,
        "phone": mobileNumber.text
      };
      print('bodyyyyyy');
      print(body);
      final response = await dio.post(
        apiUrl,
        data: body,
      );
      print('responseeeeeeee  $response');

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the response

        final Map<String, dynamic> responseData = response.data;
        print("respponse klya hai ${responseData["message"]}");
        if (responseData["message"] == "Driving Licence not found") {
          setState(() {
            dlverified = false;
            _loading = false;
          });
          print('driver is not verified');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Please enter correct License number')));
        } else {
          setState(() {
            dlverified = true;
            _loading = false;

            name = responseData["driverData"]["name"];
          });
          print('driver is verified , cool !');
        }
        // Store the response data in variables or state
        // For example, you can store it in a variable in the stateful widget
        // or update the UI with the response data
        print(responseData); // print the response for demonstration
      } else {
        // Handle any errors or exceptions
        print('Request failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Driving License not found')));
      }
    } on DioError catch (error) {
      setState(() {
        dlverified = false;
        _loading = false;
        // name=responseData["driverData"]["name"];
      });
      print("debug 3");

      print(error.response!.data);
      print("error == $error");
      Fluttertoast.showToast(
          msg: "Driving Licence not found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      // if (error.type == DioErrorType.connectTimeout) {
      //   throw SocketException(error.message);
      // }
    } catch (exception) {
      print("debug 4");
      return;
    }
  }

  @override
  void dispose() {
    myFocusNode.dispose();

    super.dispose();
  }

  void showErrorSnackbar(context, message) {
    var title = "Error";
    Flushbar(
      title: title,
      backgroundColor: Colors.red,
      message: message,
      duration: const Duration(seconds: 3),
    ).show(context);
  }

  onTapFunction({required BuildContext context}) async {
    // var datePicked = await DatePicker.showSimpleDatePicker(
    //   textColor: Colors.white,
    //             context,itemTextStyle: TextStyle(),
    //             // firstDate: DateTime.now(),
    //             lastDate: DateTime(1955),
    //             // backgroundColor: Colors.white,
    //             dateFormat: "dd-MM-yyyy",
    //             locale: DateTimePickerLocale.en_us,
    //             looping: true,

    //             initialDate: DateTime.now(),

    //           );

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,

      locale: const Locale('en', 'IN'),
      fieldHintText: 'dd-MM-yyyy',
      // errorFormatText: 'dd',
      // currentDate: DateTime(2004),
      // barrierColor: Colors.red,
      lastDate: DateTime.now(),
      firstDate: DateTime(1955),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    datePickerController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
  }

  void viewImage(File image) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Image.memory(
                image.readAsBytesSync(),
                fit: BoxFit.cover,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ));
      },
    );
  }

  Future<void> validateAndSave() async {
    if (datePickerController.text.isEmpty) {
      if (datePickerController.text == '') {
        showErrorSnackbar(context, "Please Enter Dob");
        return;
      }
    }
    if (mobileNumber.text.isEmpty) {
      showErrorSnackbar(context, "Please Enter Your Mobile Number");
      return;
    }
    if (licenseno.text.isEmpty) {
      if (licenseno.text == '') {
        showErrorSnackbar(context, "Please Enter DL License");
        return;
      }
    }
    if (licenseno.text.isNotEmpty) {
      if (licenseno.text.length > 15 && licenseno.text.length<17) {
      } else {
        showErrorSnackbar(context, "Please Enter Correct Format of DL License");

        return;
      }
    }
    if (dlverified == false) {
      showErrorSnackbar(context, "Please Verify License");
      return;
    }

    if (drivingLicenceFront.pickedImage().path.isEmpty) {
      showErrorSnackbar(context, "Please Enter Licence Front Side Photo");
      return;
    }
    if (drivingLicenceBack.pickedImage().path.isEmpty) {
      showErrorSnackbar(context, "Please Enter Licence Front Side Photo");
      return;
    }

    if (_vehicleDetailType == null) {
      showErrorSnackbar(context, "Please Pick Your Vehicle Type");
      return;
    }

    if (vehicleNumber.text.isEmpty) {
      showErrorSnackbar(context, "Please Enter Your VehicleNumber");
      return;
    }

    if (rcverified == false) {
      showErrorSnackbar(context, "Please Verify Rc");
      return;
    }

    if (rCBook.pickedImage().path.isEmpty) {
      showErrorSnackbar(context, "Please Enter Rc Photo");
      return;
    }

    //when all things are correct
    // context.router.push(const HomePageRoute());
    String carType = "";
    if (VehicleDetailType.auto == _vehicleDetailType) {
      carType = "AUTO";
    } else if (VehicleDetailType.sedan == _vehicleDetailType) {
      carType = "SEDAN";
    } else if (VehicleDetailType.hatchback == _vehicleDetailType) {
      carType = "HATCHBACK";
    } else {
      carType = "SUV";
    }
    print("Success");
    UtilDialog.showWaiting(context);
    SharedPreferences pref = await SharedPreferences.getInstance();
    // Map<String, dynamic> json =
    //     jsonDecode(pref.getString(AppConstants.userDataKey) ?? "");

    // authCubit
    //     .uploadImage(drivingLicenceFront.pickedImage())
    //     .then((drivingLicenceFrontUrl) {
    //   String register = jsonEncode(SignupRequestModel(
    //           drivingLicense: drivingLicenceFrontUrl, phone: mobileNumber.text)
    //       .toJson());
    // pref.setString(AppConstants.registerData, register);
    // pref.setBool("isDetailDone", true);
    // print(drivingLicenceFrontUrl);
    // DriverDetailsEntity driverDetailsEntity = DriverDetailsEntity(
    //     DateTime.now().toString(),
    //     mobileNumber: mobileNumber.text,
    //     licenseno: licenseno.text,
    //     upiId: upiID.text,
    //     licenceFrontSide: drivingLicenceFrontUrl,
    //     licenceBackSide: "");
    // UtilDialog.hideWaiting(context);
    // print(licenseno.text);
    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) =>
    //           VehicleDetails(driverDetailsEntity: driverDetailsEntity),
    //     ));
    // });
  }

  void _requestFocus() {
    setState(() {
      // FocusScope.of(context).requestFocus(myFocusNode);
    });
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
        _controller = TabController(vsync: this, length: 2,initialIndex: 1);

  }
  @override
  Widget build(BuildContext context) {
    bool isImageFrontVisible =
        drivingLicenceFront.pickedImage().path.isNotEmpty ?? false;
    bool isImageBackVisible =
        drivingLicenceBack.pickedImage().path.isNotEmpty ?? false;
    return Scaffold(
      body: CustomScrollView(

        slivers:<Widget>[ SliverList(
          delegate: SliverChildListDelegate(
            [Padding(
              padding:                       const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            
              child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
              
                children: [
                  Vspace(32),
                  Text("Driver Onboarding",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
                  Vspace(16),
                        const Text("Driver Mobile Number"),
                  const Vspace(16),
                  TextField(
                    // onChanged: (value) {
                    //   if (value.length == 15) {
                    //     setState(() {
                    //       postData(value);
                    //     });
                    //   }
                    // },
                    // focusNode: myFocusNode,
                    onTap: _requestFocus,
                    // enabled: widget.isEnabled,
                    keyboardType: TextInputType.phone,
                    controller: mobileNumber,
              
                    // style: TextStyle(color: AppColors.primaryGreen),
                    cursorColor: AppColors.black,
                    maxLength: 10,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                        labelText: "Mobile Number",
                        // hintText: "",
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color:
                                AppColors.primaryGreen, // Customize the outline color
                          ),
                        ),
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? AppColors.primaryGreen
                                : Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AppColors
                                .primaryGreen, // Customize the focus outline color
                          ),
                        ),
                        focusColor: AppColors.primaryGreen,
                        fillColor: AppColors.primaryGreen,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.call),
                        )),
                  ),
                  // SizedBox(
                  //   width: double.infinity,
                  //   child: TabContainer(tabs: [
                  //     Text("1"),
                  //     Text("1")
                  //   ],
                  //     // color: AppColors.primaryGreen,
                  //     controller: _controller,
                  //                   borderRadius: BorderRadius.circular(20),
                  //     tabEdge: TabEdge.top,
                  //     curve: Curves.easeIn,
                  //     transitionBuilder: (child, animation) {
                  //       animation = CurvedAnimation(
                  //           curve: Curves.easeIn, parent: animation);
                  //       return SlideTransition(
                  //         position: Tween(
                  //           begin: const Offset(0.2, 0.0),
                  //           end: const Offset(0.0, 0.0),
                  //         ).animate(animation),
                  //         child: FadeTransition(
                  //           opacity: animation,
                  //           child: child,
                  //         ),
                  //       );
                  //     },
                    
                  //   //   selectedTextStyle:
                  //   //       textTheme.bodyMedium?.copyWith(fontSize: 15.0),
                  //   //   unselectedTextStyle:
                  //   //       textTheme.bodyMedium?.copyWith(fontSize: 13.0),
                  //   children: [
                      
                  //     Container(
                  //       color: AppColors.white,
                  //       child: Text("data1")),Text("data2")],
                  //   ),
                  // ),
Container(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      GestureDetector(
        onTap: () {
          setState(() {
            selectedDlindex=0;
          });
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)),        color:selectedDlindex==0? AppColors.primaryGreen:AppColors.grey,),
          height:48,
          child: Center(
            child: Text(
              "API",
            style: TextStyle(color: Colors.white,fontSize: 18),
            ),
          ),
          width: MediaQuery.of(context).size.width*0.45,
        ),
      ),
      GestureDetector(
        onTap: () {
          setState(() {
            selectedDlindex=1;
          });
        },
        child: Container(height:48,
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)),        color: selectedDlindex==1? AppColors.primaryGreen:AppColors.grey,),
        width: MediaQuery.of(context).size.width*0.45,
           child: Center(
            child: Text(
              "MANUAL",
            style: TextStyle(color: Colors.white,fontSize: 18),
            ),
          ),
        ),
      )    ],
  ),
),
      selectedDlindex==0?
Container(
  child: Column(

    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Vspace(16),
           const Text("DOB  (Date of Birth)"),
                  const Vspace(16),
                  TextField(
                      enabled: true,
                      keyboardType: TextInputType.datetime,
                      controller: datePickerController,
                      // style: TextStyle(color: AppColors.primaryGreen),
                      cursorColor: AppColors.black,
                      focusNode: myFocusNode,
                      onTap: () {
                        // _requestFocus;
                        onTapFunction(context: context);
                      },
                      // inputFormatters: [],
              
                      decoration: InputDecoration(
                        labelText: "DOB",
                        hintText: "02-05-2004",
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color:
                                AppColors.primaryGreen, // Customize the outline color
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: myFocusNode.hasFocus
                              ? AppColors.primaryGreen
                              : Colors.black,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AppColors
                                .primaryGreen, // Customize the focus outline color
                          ),
                        ),
                        focusColor: AppColors.primaryGreen,
                        fillColor: AppColors.primaryGreen,
                        prefixIcon: const Icon(Icons.date_range),
                      )),
                  const Vspace(16),
                  const Text("Driving License Number"),
                  const Vspace(16),
                  TextField(
                    // onChanged: (value) {
                    //   if (value.length == 15) {
                    //     setState(() {
                    //       postData(value);
                    //     });
                    //   }
                    // },
                    // focusNode: myFocusNode,
                    onTap: _requestFocus,
                    // enabled: widget.isEnabled,
                    keyboardType: TextInputType.emailAddress,
                    controller: licenseno,
              
                    // style: TextStyle(color: AppColors.primaryGreen),
                    cursorColor: AppColors.black,
                    // maxLength: ,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                        labelText: "License No",
                        hintText: "XXXXXXXXXXXX",
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color:
                                AppColors.primaryGreen, // Customize the outline color
                          ),
                        ),
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? AppColors.primaryGreen
                                : Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AppColors
                                .primaryGreen, // Customize the focus outline color
                          ),
                        ),
                        focusColor: AppColors.primaryGreen,
                        fillColor: AppColors.primaryGreen,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.insert_drive_file_rounded),
                        )),
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          if (dlverified)
                            SvgPicture.asset("assets/icons/complete.svg",
                                color: Colors.green),
                          if (!dlverified)
                            SvgPicture.asset("assets/icons/pending.svg",
                                color: const Color(0xff707070)),
                          const SizedBox(
                              width: 10), // Add some space between icon and text
                          Text(
                            dlverified ? name : "Verification pending",
                            style: TextStyle(
                              color: dlverified ? Colors.green : const Color(0xff707070),
                            ),
                          ),
                          const Spacer(),
                          MaterialButton(
                            onPressed: () {
                              if (licenseno.text.length == 15) {
                                setState(() {
                                  _loading = true;
              
              // verified=tr
                                });
                                verifyDl(licenseno.text);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text(
                                        'Please enter correct License number format')));
                              }
                            },
                            color: AppColors.primaryGreen,
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Verify",
                                    style: TextStyle(color: AppColors.white),
                                  ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const Vspace(15),
                
    ],
  ),
):Container(
  child: Column(

    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Vspace(16),
           const Text("DOB  (Date of Birth)"),
                  const Vspace(16),
                  TextField(
                      enabled: true,
                      keyboardType: TextInputType.datetime,
                      controller: datePickerController,
                      // style: TextStyle(color: AppColors.primaryGreen),
                      cursorColor: AppColors.black,
                      focusNode: myFocusNode,
                      onTap: () {
                        // _requestFocus;
                        onTapFunction(context: context);
                      },
                      // inputFormatters: [],
              
                      decoration: InputDecoration(
                        labelText: "DOB",
                        hintText: "02-05-2004",
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color:
                                AppColors.primaryGreen, // Customize the outline color
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: myFocusNode.hasFocus
                              ? AppColors.primaryGreen
                              : Colors.black,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AppColors
                                .primaryGreen, // Customize the focus outline color
                          ),
                        ),
                        focusColor: AppColors.primaryGreen,
                        fillColor: AppColors.primaryGreen,
                        prefixIcon: const Icon(Icons.date_range),
                      )),
                  const Vspace(16),
                  const Text("Driving License Number"),
                  const Vspace(16),
                  TextField(
                    // onChanged: (value) {
                    //   if (value.length == 15) {
                    //     setState(() {
                    //       postData(value);
                    //     });
                    //   }
                    // },
                    // focusNode: myFocusNode,
                    onTap: _requestFocus,
                    // enabled: widget.isEnabled,
                    keyboardType: TextInputType.emailAddress,
                    controller: licenseno,
              
                    // style: TextStyle(color: AppColors.primaryGreen),
                    cursorColor: AppColors.black,
                    // maxLength: ,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                        labelText: "License No",
                        hintText: "XXXXXXXXXXXX",
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color:
                                AppColors.primaryGreen, // Customize the outline color
                          ),
                        ),
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? AppColors.primaryGreen
                                : Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AppColors
                                .primaryGreen, // Customize the focus outline color
                          ),
                        ),
                        focusColor: AppColors.primaryGreen,
                        fillColor: AppColors.primaryGreen,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.insert_drive_file_rounded),
                        )),
                  ),
                                    const Vspace(16),

                      const Text("Driver Address"),
                  const Vspace(16),
                  TextField(
                    // onChanged: (value) {
                    //   if (value.length == 15) {
                    //     setState(() {
                    //       postData(value);
                    //     });
                    //   }
                    // },
                    // focusNode: myFocusNode,
                    onTap: _requestFocus,
                    // enabled: widget.isEnabled,
                    keyboardType: TextInputType.streetAddress,
                    // controller: licenseno,
              
                    // style: TextStyle(color: AppColors.primaryGreen),
                    cursorColor: AppColors.black,
                    // maxLength: ,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                        labelText: "Driver Address",
                        // hintText: "",
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color:
                                AppColors.primaryGreen, // Customize the outline color
                          ),
                        ),
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? AppColors.primaryGreen
                                : Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AppColors
                                .primaryGreen, // Customize the focus outline color
                          ),
                        ),
                        focusColor: AppColors.primaryGreen,
                        fillColor: AppColors.primaryGreen,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.map_outlined),
                        )),
                  ),
                           const Vspace(16),

                      const Text("Driver License Category"),
                  const Vspace(16),
                  TextField(
                    // onChanged: (value) {
                    //   if (value.length == 15) {
                    //     setState(() {
                    //       postData(value);
                    //     });
                    //   }
                    // },
                    // focusNode: myFocusNode,
                    onTap: _requestFocus,
                    // enabled: widget.isEnabled,
                    keyboardType: TextInputType.streetAddress,
                    // controller: licenseno,
              
                    // style: TextStyle(color: AppColors.primaryGreen),
                    cursorColor: AppColors.black,
                    // maxLength: ,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                        labelText: "License Category",
                        // hintText: "",
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color:
                                AppColors.primaryGreen, // Customize the outline color
                          ),
                        ),
                        labelStyle: TextStyle(
                            color: myFocusNode.hasFocus
                                ? AppColors.primaryGreen
                                : Colors.black),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AppColors
                                .primaryGreen, // Customize the focus outline color
                          ),
                        ),
                        focusColor: AppColors.primaryGreen,
                        fillColor: AppColors.primaryGreen,
                       ),
                  ),
                  
                      const Text("Gender"),
                  const Vspace(16),
                  DropdownButton<String>(
                    
                    items:  <DropdownMenuItem<String>>[
                       DropdownMenuItem<String>(
                  value: 'Male',
                  child: Text('Male'),
                ),
                DropdownMenuItem<String>(
                  value: 'Female',
                  child: Text('Female'),
                ),
                      // <DropdownMenuItem<String>>(child: Text("Male"),value: 'Male'),
                      // <DropdownMenuItem<String>>(child: Text("Female"),value: "Female"),
                    ],
value: 'Male',
              // isExpanded: true, // Optional: Makes the dropdown take the full width of its container

                    onChanged: (value){

                    }),
                    // decoration: InputDecoration(
                    //     labelText: "GENDER",
                    //     // hintText: "",
                    //     contentPadding:
                    //         const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(4),
                    //       borderSide: const BorderSide(
                    //         color:
                    //             AppColors.primaryGreen, // Customize the outline color
                    //       ),
                    //     ),
                    //     labelStyle: TextStyle(
                    //         color: myFocusNode.hasFocus
                    //             ? AppColors.primaryGreen
                    //             : Colors.black),
                    //     focusedBorder: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(4),
                    //       borderSide: const BorderSide(
                    //         color: AppColors
                    //             .primaryGreen, // Customize the focus outline color
                    //       ),
                    //     ),
                    //     focusColor: AppColors.primaryGreen,
                    //     fillColor: AppColors.primaryGreen,
                    //    ),
                
                  Column(
                    children: [
                      Row(
                        children: [
                          if (dlverified)
                            SvgPicture.asset("assets/icons/complete.svg",
                                color: Colors.green),
                          if (!dlverified)
                            SvgPicture.asset("assets/icons/pending.svg",
                                color: const Color(0xff707070)),
                          const SizedBox(
                              width: 10), // Add some space between icon and text
                          Text(
                            dlverified ? name : "Verification pending",
                            style: TextStyle(
                              color: dlverified ? Colors.green : const Color(0xff707070),
                            ),
                          ),
                          const Spacer(),
                          MaterialButton(
                            onPressed: () {
                              if (licenseno.text.length == 15) {
                                setState(() {
                                  _loading = true;
              
              // verified=tr
                                });
                                verifyDl(licenseno.text);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                    content: Text(
                                        'Please enter correct License number format')));
                              }
                            },
                            color: AppColors.primaryGreen,
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Verify",
                                    style: TextStyle(color: AppColors.white),
                                  ),
                          )
                        ],
                      ),
                    ],
                  ),
                  const Vspace(15),
                
    ],
  ),
),

               Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        // height: ,
                        width: MediaQuery.of(context).size.width / 2.3,
                        child: Column(
                          children: [
                            const Vspace(15),
                            drivingLicenceFront.pickedImage().path.isNotEmpty
                                ? SizedBox.fromSize()
                                : UploadImageWidget(
                                    onTap: () {
                                      drivingLicenceFront.showImagePicker(context, () {
                                        setState(() {});
                                      });
                                    },
                                    title: "Upload Front Side Driving License",
                                  ),
                            isImageFrontVisible
                                ? Column(
                                    children: [
                                      const BigTitle(bigTitle: "Front Side"),
                                      Stack(
                                        children: [
                                          Image.file(
                                              drivingLicenceFront
                                                  .pickedImage()
                                                  .absolute,
                                              height: 150),
                                          Positioned(
                                            top: 2,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: () {
                                                // Handle cancel button press here
                                                drivingLicenceFront = ImagePickerUtil();
              
                                                setState(() {
                                                  isImageFrontVisible = false;
                                                });
                                              },
                                              child: const Icon(
                                                Icons.cancel,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : SizedBox.fromSize(),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.3,
                        child: Column(
                          children: [
                            const Vspace(15),
                            drivingLicenceBack.pickedImage().path.isNotEmpty
                                ? SizedBox.fromSize()
                                : UploadImageWidget(
                                    onTap: () {
                                      drivingLicenceBack.showImagePicker(context, () {
                                        setState(() {});
                                      });
                                    },
                                    title: "Upload Back Driving License",
                                  ),
                            isImageBackVisible
                                ? Column(
                                    children: [
                                      const BigTitle(bigTitle: "Back Side"),
                                      Stack(
                                        children: [
                                          Image.file(
                                              drivingLicenceBack.pickedImage().absolute,
                                              height: 150),
                                          Positioned(
                                            top: 2,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: () {
                                                // Handle cancel button press here
                                                drivingLicenceBack = ImagePickerUtil();
              
                                                setState(() {
                                                  isImageBackVisible = false;
                                                });
                                              },
                                              child: const Icon(
                                                Icons.cancel,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : SizedBox.fromSize(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Vspace(20),
                  const Text("UPI ID"),
                  const Vspace(16),
                  CustomTextField(
                    label: "UPI ID",
                    controller: upiID,
                    hint: "ex.12345678@ybi",
                    image: Image.asset(
                      "assets/images/upi.png",
                      height: 10,
                    ),
                  ),
                       const BigTitle(
                        bigTitle: "Vehicle Details",
                        fontSize: 15.999998092651367,
                        fontWeight: FontWeight.w600,
                      ),
                      const Vspace(16),
                      CustomTextField(
                          label: "Vehicle Number",
                          controller: vehicleNumber,
                          hint: "Ex. GJ25R5577",
                          image: Image.asset(
                            "assets/images/num_plate.png",
                            height: 24,
                            width: 24,
                          ),
                          onChanged: (value) {
                            // Handle text changes here
                            if (value.isNotEmpty && value.length == 10) {
                              //  postData();
                            }
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (rcverified)
                                SvgPicture.asset("assets/icons/complete.svg",
                                    color: Colors.green),
                              if (!rcverified)
                                SvgPicture.asset("assets/icons/pending.svg",
                                    color: const Color(0xff707070)),
                              const SizedBox(
                                  width:
                                      10), // Add some space between icon and text
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      FittedBox(
                                        child: Text(
                                          rcverified
                                              ? (vehiclenamemodel
                                                          .toString()
                                                          .length >
                                                      25
                                                  ? vehiclenamemodel
                                                      .toString()
                                                      .substring(0, 25)
                                                  : vehiclenamemodel.toString())
                                              : "Verification pending",
                                          style: TextStyle(
                                            color: rcverified
                                                ? AppColors.primaryGreen
                                                : const Color(0xff707070),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          MaterialButton(
                            onPressed: () {
                              setState(() {
                                _loading = true;
                              });
                              verifyRC();
                            },
                            color: AppColors.primaryGreen,
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Check",
                                    style: TextStyle(color: AppColors.white),
                                  ),
                          )
                        ],
                      ),
                      const TextWidget(
                        text: "Vehicle Type",
                        fontSize: 13.999999046325684,
                        fontWeight: FontWeight.w500,
                      ),
                      const Vspace(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DecoratedContainer(
                              height: 110,
                              width: MediaQuery.of(context).size.width * .42,
                              borderRadius: 8,
                              containerColor:
                                  _vehicleDetailType == VehicleDetailType.auto
                                      ? AppColors.white
                                      : Colors.transparent,
                              borderColor:
                                  _vehicleDetailType == VehicleDetailType.auto
                                      ? AppColors.primaryGreen
                                      : Colors.black12,
                              borderWidth: 1,
                              onTap: () {
                                setState(() {
                                  _vehicleDetailType = VehicleDetailType.auto;
                                });
                              },
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const TextWidget(text: "Auto"),
                                  SvgPicture.asset(
                                    'assets/icons/tuc-tuc.svg',
                                    height: 48,
                                    width: 48,
                                  )
                                ],
                              )),
                          // const Hspace(40),
                          DecoratedContainer(
                              height: 110,
                              width: MediaQuery.of(context).size.width * .42,
                              borderRadius: 8,
                              containerColor:
                                  _vehicleDetailType == VehicleDetailType.sedan
                                      ? AppColors.white
                                      : Colors.transparent,
                              borderColor:
                                  _vehicleDetailType == VehicleDetailType.sedan
                                      ? AppColors.primaryGreen
                                      : Colors.black12,
                              borderWidth: 1,
                              onTap: () {
                                setState(() {
                                  _vehicleDetailType = VehicleDetailType.sedan;
                                });
                              },
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const TextWidget(text: "Sedan"),
                                  SvgPicture.asset(
                                    'assets/icons/sedan.svg',
                                    height: 48,
                                    width: 48,
                                  )
                                ],
                              )),
                        ],
                      ),
                      const Vspace(16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DecoratedContainer(
                              height: 110,
                              width: MediaQuery.of(context).size.width * .42,
                              borderRadius: 8,
                              containerColor: _vehicleDetailType ==
                                      VehicleDetailType.hatchback
                                  ? AppColors.white
                                  : Colors.transparent,
                              borderColor: _vehicleDetailType ==
                                      VehicleDetailType.hatchback
                                  ? AppColors.primaryGreen
                                  : Colors.black12,
                              borderWidth: 1,
                              onTap: () {
                                setState(() {
                                  _vehicleDetailType =
                                      VehicleDetailType.hatchback;
                                });
                              },
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const TextWidget(text: "Hatchback"),
                                  SvgPicture.asset(
                                    'assets/icons/hatchback.svg',
                                    height: 48,
                                    width: 48,
                                  )
                                ],
                              )),
                          // const Hspace(40),
                          DecoratedContainer(
                              height: 110,
                              width: MediaQuery.of(context).size.width * .42,
                              borderRadius: 8,
                              containerColor:
                                  _vehicleDetailType == VehicleDetailType.suv
                                      ? AppColors.white
                                      : Colors.transparent,
                              borderColor:
                                  _vehicleDetailType == VehicleDetailType.suv
                                      ? AppColors.primaryGreen
                                      : Colors.black12,
                              borderWidth: 1,
                              onTap: () {
                                setState(() {
                                  _vehicleDetailType = VehicleDetailType.suv;
                                });
                              },
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const TextWidget(text: "SUV"),
                                  SvgPicture.asset(
                                    'assets/icons/suv.svg',
                                    height: 48,
                                    width: 48,
                                  )
                                ],
                              )),
                        ],
                      ),
                      const Vspace(16),
                      const BigTitle(
                        bigTitle: "Upload RC Book",
                        fontSize: 13.999999046325684,
                        fontWeight: FontWeight.w500,
                      ),
                      rCBook.pickedImage().path.isNotEmpty
                          ? UploadedFileWidget(
                              name: rCBook.pickedImage().path.split('/').last,
                              removeImage: () {
                                rCBook = ImagePickerUtil();
                                setState(() {});
                              },
                              viewImage: () =>
                                  viewImage(rCBook.pickedImage().absolute),
                            )
                          : const SizedBox.shrink(),
                      const Vspace(10),
                      rCBook.pickedImage().path.isNotEmpty
                          ? SizedBox.fromSize()
                          : UploadImageWidget(
                              onTap: () {
                                rCBook.showImagePicker(context, () {
                                  setState(() {});
                                });
                              },
                              title: "Upload Rc Book",
                            ),
                      const Vspace(41),
                ],
              ),
            ),
          
             ] ),
            )
        ]
      )
    );
  }
}
class UploadedFileWidget extends StatelessWidget {
  final Function() removeImage;
  final Function() viewImage;
  final String name;

  const UploadedFileWidget({
    super.key,
    required this.removeImage,
    required this.viewImage,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Vspace(8),
        const Vspace(10),
        DecoratedContainer(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.photo, color: Colors.black38),
              const Hspace(20),
              SizedBox(
                  width: MediaQuery.of(context).size.width - 200,
                  child: TextWidget(text: name)),
              const Expanded(child: Hspace(0)),
              GestureDetector(
                onTap: () {
                  viewImage();
                },
                child: const Icon(
                  Icons.visibility,
                  color: Color(0xff999999),
                ),
              ),
              const Hspace(17),
              GestureDetector(
                onTap: () {
                  removeImage();
                },
                child: const Icon(
                  Icons.close,
                  color: Color(0xff999999),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UploadImageWidget extends StatelessWidget {
  final title;
  const UploadImageWidget({super.key, required this.onTap, this.title});

  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: DottedBorder(
          color: const Color(0xffD0D5DD),
          dashPattern: const [6, 8],
          strokeCap: StrokeCap.round,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // const Vspace(16),
                  // SvgPicture.asset(AppIcons.upload),
                  TextWidget(text: title),
                  // const Vspace(16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  const CustomTextField(
      {super.key,
      required this.hint,
      required this.label,
      required this.controller,
      this.icon,
      this.image,
      this.textInputType,
      this.maxlength,
      this.prefixIcon,
      this.onChanged, // Add onChanged callback

      this.isEnabled = true});

  final String hint;
  final TextEditingController controller;
  final Icon? icon;
  final int? maxlength;
  final Image? image;
  final String label;
  final bool isEnabled;
  final TextInputType? textInputType;
  final Widget? prefixIcon;
  final void Function(String)?
      onChanged; // Callback function for onChanged event

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  FocusNode myFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  void _requestFocus() {
    setState(() {
      FocusScope.of(context).requestFocus(myFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
        focusNode: myFocusNode,
        onChanged: widget.onChanged, // Call the onChanged callback

        onTap: _requestFocus,
        enabled: widget.isEnabled,
        keyboardType: TextInputType.emailAddress,
        controller: widget.controller,
        // style: TextStyle(color: AppColors.primaryGreen),
        cursorColor: AppColors.black,
        maxLength: widget.maxlength,
        decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: AppColors.primaryGreen, // Customize the outline color
              ),
            ),
            labelStyle: TextStyle(
                color: myFocusNode.hasFocus
                    ? AppColors.primaryGreen
                    : Colors.black),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color:
                    AppColors.primaryGreen, // Customize the focus outline color
              ),
            ),
            focusColor: AppColors.primaryGreen,
            fillColor: AppColors.primaryGreen,
            prefixIcon: widget.icon));
  }
}

class TextLable extends StatelessWidget {
  const TextLable({
    super.key,
    required this.label,
    this.fontSize,
    this.fontWeight,
  });

  final String label;
  final double? fontSize;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return TextWidget(
      text: label,
      color: AppColors.blackColor,
      fontSize: fontSize ?? 12,
      fontWeight: fontWeight ?? FontWeight.w400,
    );
  }
}

class BigTitle extends StatelessWidget {
  const BigTitle({
    super.key,
    required this.bigTitle,
    this.fontWeight,
    this.fontSize,
  });

  final String bigTitle;
  final FontWeight? fontWeight;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return TextWidget(
      text: bigTitle,
      color: const Color(0xff393939),
      fontSize: fontSize ?? 17,
      fontWeight: fontWeight ?? FontWeight.w400,
    );
  }
}
