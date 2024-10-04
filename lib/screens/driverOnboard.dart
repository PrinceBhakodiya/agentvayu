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

class _DriverOnboardState extends State<DriverOnboard>
    with SingleTickerProviderStateMixin {
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
  TextEditingController licenseaddress = TextEditingController();
  // TextEditingController licenseCategory = TextEditingController();
  TextEditingController dlvalid = TextEditingController();
  TextEditingController rcvalid = TextEditingController();
  // TextEditingController vehiclefuel = TextEditingController();
  TextEditingController vehicleMakermodel = TextEditingController();
  TextEditingController nameC = TextEditingController();
  String vehiclefuel = "CNG";

  String licenseCategory = "MCWG";

  String gender = "Male";
  ImagePickerUtil driverPhoto = ImagePickerUtil();
  ImagePickerUtil drivingLicenceFront = ImagePickerUtil();
  ImagePickerUtil drivingLicenceBack = ImagePickerUtil();
  ImagePickerUtil rCBook = ImagePickerUtil();
  int selectedDlindex = 0;
  int selectedRcindex = 0;

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
    if (mobileNumber.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter mobile number')));
      return;
    }
    const String apiUrl = '${AppConstants.baseUrl}/rcVerify';

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
    if (mobileNumber.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter mobile number')));
      return;
    }
    setState(() {
      _loading = true;

      // verified=tr
    });
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

  Future<void> dlVerificationFailed() async {
    print("IN");
    if (mobileNumber.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter mobile number')));
      return;
    }
    if (mobileNumber.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter correct mobile number')));
      return;
    }
    if (nameC.text == "") {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter Name')));
      return;
    }
    if (datePickerController.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Date of birth')));
      return;
    }
    if (licenseno.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter License Number')));
      return;
    }
    if (licenseaddress.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Driver Address')));
      return;
    }
    if (licenseCategory == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter License Category ')));
      return;
    }
    if (dlvalid.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter License Valid upto date')));
      return;
    }

    print(datePickerController.text);
    DateTime parsedDate =
        DateFormat('dd-MM-yyyy').parse(datePickerController.text);
    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    DateTime parsedDate2 = DateFormat('dd-MM-yyyy').parse(dlvalid.text);
    String formattedDate2 = DateFormat('yyyy-MM-dd').format(parsedDate2);
    const String apiUrl = '${AppConstants.baseUrl}/dlVerificationFailed';
    try {
      print(apiUrl);
      var body = {
        "driverAddress": licenseaddress.text,
        "drivingLicenseCategory": licenseCategory,
        "gender": gender,
        "drivingLicenseValidUpto": formattedDate2,
        "name": nameC.text,
        "dob": datePickerController.text,
        "licenseNumber": licenseno.text,
        "mobile": mobileNumber.text
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

        print(response.data);
        // if (responseData["message"] == "Driving Licence not found") {
        setState(() {
          dlverified = true;
          _loading = false;
        });

        // } else {
        //   setState(() {
        //     dlverified = true;
        //     _loading = false;

        //     name = responseData["driverData"]["name"];
        //   });
        //     print('driver is verified , cool !');
        //   }
        //   // Store the response data in variables or state
        //   // For example, you can store it in a variable in the stateful widget
        //   // or update the UI with the response data
        //   print(responseData); // print the response for demonstration
        // } else {
        //   // Handle any errors or exceptions
        //   print('Request failed with status: ${response.statusCode}');
        //   ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('Driving License not found')));
        // }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> rcVerificationFailed() async {
    if (mobileNumber.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter mobile number')));
      return;
    }
    if (mobileNumber.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter correct mobile number')));
      return;
    }
    if (vehicleMakermodel.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter vehicle model')));
      return;
    }
    if (vehicleNumber.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Vehicle Number')));
      return;
    }
    if (vehiclefuel == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter Vehicle Fuel Type')));
      return;
    }

    if (rcvalid.text == "") {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter RC Valid upto date')));
      return;
    }

    DateTime parsedDate = DateFormat('dd-MM-yyyy').parse(rcvalid.text);
    String formattedDate = DateFormat('yyyy-MM-dd').format(parsedDate);
    const String apiUrl = '${AppConstants.baseUrl}/rcVerificationFailed';
    try {
      var body = {
        "driverAddress": licenseaddress.text,
        "vehicleNumber": vehicleNumber.text,
        "vehicleMakerModel": vehicleMakermodel.text,
        "vehicleFuelType": vehiclefuel,
        "rcValidUpto": formattedDate,
        "mobile": mobileNumber.text
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
        print(response.data);
        // if (responseData["message"] == "Driving Licence not found") {
        setState(() {
          rcverified = true;
          _loading = false;
        });

        // } else {
        //   setState(() {
        //     dlverified = true;
        //     _loading = false;

        //     name = responseData["driverData"]["name"];
        //   });
        //     print('driver is verified , cool !');
        //   }
        //   // Store the response data in variables or state
        //   // For example, you can store it in a variable in the stateful widget
        //   // or update the UI with the response data
        //   print(responseData); // print the response for demonstration
        // } else {
        //   // Handle any errors or exceptions
        //   print('Request failed with status: ${response.statusCode}');
        //   ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('Driving License not found')));
        // }
      }
    } catch (e) {
      print(e.toString());
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

  onTapFunction2({required BuildContext context}) async {
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
      lastDate: DateTime(2050),
      firstDate: DateTime(1980),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    dlvalid.text = DateFormat('dd-MM-yyyy').format(pickedDate);
  }

  onTapFunction3({required BuildContext context}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,

      locale: const Locale('en', 'IN'),
      fieldHintText: 'dd-MM-yyyy',
      // errorFormatText: 'dd',
      // currentDate: DateTime(2004),
      // barrierColor: Colors.red,
      lastDate: DateTime(2050),
      firstDate: DateTime(1980),
      initialDate: DateTime.now(),
    );
    if (pickedDate == null) return;
    rcvalid.text = DateFormat('dd-MM-yyyy').format(pickedDate);
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

  Future<String> uploadImage(File file) async {
    Dio dio = Dio();
    dio.options.headers["Content-Type"] = "multipart/form-data";
    String fileName = file.path.split('/').last;

    final newFile = await MultipartFile.fromFile(file.path, filename: fileName);
    FormData formData = FormData.fromMap({
      "file": newFile,
      // "content-type": MediaType("image", "jpeg"),
    });
    print("debug 1");
    final response = await dio.post('${AppConstants.ONDCbaseUrl}/uploadMedia',
        data: formData);
    print(response.statusCode);
    print("image");

    if (response.statusCode == 200) {
      print("in image");
      print(response.data);
      return response.data['result'];
    } else {
      return "null";
    }
  }

  Future<void> validateAndSave() async {
    if (mobileNumber.text.isEmpty) {
      showErrorSnackbar(context, "Please Enter Your Mobile Number");
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

    if (rcverified == false) {
      showErrorSnackbar(context, "Please Verify Rc");
      return;
    }
    if (dlverified == false) {
      showErrorSnackbar(context, "Please Verify Driving License");
      return;
    }

    if (rCBook.pickedImage().path.isEmpty) {
      showErrorSnackbar(context, "Please Enter Rc Photo");
      return;
    }

    if (driverPhoto.pickedImage().path.isEmpty) {
      showErrorSnackbar(context, "Please Enter Profile Photo");
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
    String dlUrl = await uploadImage(drivingLicenceFront.pickedImage());
        String dlUrlBack = await uploadImage(drivingLicenceBack.pickedImage());

    String rcUrl = await uploadImage(rCBook.pickedImage());

    String proUrl = await uploadImage(driverPhoto.pickedImage());
    String referCode = pref.getString("refer") ?? "";
    Dio dio = Dio();
    var body = {
      "phone": mobileNumber.text,
      "profileUrl": proUrl ?? "",
      "vehicleType": carType,
      "refferedBy": referCode,
      "drivingLicense": dlUrl ?? "",
            "drivingLicenseBack": dlUrlBack ?? "",
      "registrationCertificate": rcUrl ?? ""
    };
    try {
      print(body);
      var response = await dio.post("${AppConstants.baseUrl}/createUserByAgent",
          data: body);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.data);

        UtilDialog.hideWaiting(context);
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Driver Registered Successfully",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: AppColors.primaryGreen,
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        print(response.data);
      }
    } on DioException catch (e) {
      print(e.message);
      print("Error");
      Fluttertoast.showToast(
          msg: e.message!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      print(e.response!.data);
    } catch (e) {
      print(e);
    }
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
    _controller = TabController(vsync: this, length: 2, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    bool isImageFrontVisible =
        drivingLicenceFront.pickedImage().path.isNotEmpty ?? false;
    bool isImageBackVisible =
        drivingLicenceBack.pickedImage().path.isNotEmpty ?? false;
    return Scaffold(
      body: CustomScrollView(slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Vspace(32),
                  Text(
                    "Driver Onboarding",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: AppColors
                                .primaryGreen, // Customize the outline color
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
                  Divider(),
                  const Vspace(8),
                  const BigTitle(
                    bigTitle: "Driver Details",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  const Vspace(16),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDlindex = 0;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: selectedDlindex == 0
                                  ? AppColors.primaryGreen
                                  : AppColors.grey,
                            ),
                            height: 48,
                            child: Center(
                              child: Text(
                                "API",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.45,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDlindex = 1;
                            });
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: selectedDlindex == 1
                                  ? AppColors.primaryGreen
                                  : AppColors.grey,
                            ),
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Center(
                              child: Text(
                                "MANUAL",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  selectedDlindex == 0
                      ? Container(
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors
                                            .primaryGreen, // Customize the outline color
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
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                    labelText: "License No",
                                    hintText: "XXXXXXXXXXXX",
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors
                                            .primaryGreen, // Customize the outline color
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
                                      child:
                                          Icon(Icons.insert_drive_file_rounded),
                                    )),
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      if (dlverified)
                                        SvgPicture.asset(
                                            "assets/icons/complete.svg",
                                            color: Colors.green),
                                      if (!dlverified)
                                        SvgPicture.asset(
                                            "assets/icons/pending.svg",
                                            color: const Color(0xff707070)),
                                      const SizedBox(
                                          width:
                                              10), // Add some space between icon and text
                                      Text(
                                        dlverified
                                            ? name
                                            : "Verification pending",
                                        style: TextStyle(
                                          color: dlverified
                                              ? Colors.green
                                              : const Color(0xff707070),
                                        ),
                                      ),
                                      const Spacer(),
                                      MaterialButton(
                                        onPressed: () {
                                          if (licenseno.text.length < 15) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'Please enter correct License number format')));
                                            return;
                                          }

                                          verifyDl(licenseno.text);
                                        },
                                        color: AppColors.primaryGreen,
                                        child: _loading
                                            ? const CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : const Text(
                                                "Verify",
                                                style: TextStyle(
                                                    color: AppColors.white),
                                              ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              const Vspace(15),
                            ],
                          ),
                        )
                      : Container(
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors
                                            .primaryGreen, // Customize the outline color
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
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                    labelText: "License No",
                                    hintText: "XXXXXXXXXXXX",
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors
                                            .primaryGreen, // Customize the outline color
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
                                      child:
                                          Icon(Icons.insert_drive_file_rounded),
                                    )),
                              ),
                              const Vspace(16),
                              const Text("Driver Name"),
                              const Vspace(16),
                              TextField(
                                keyboardType: TextInputType.text,
                                cursorColor: AppColors.black,
                                controller: nameC,
                                decoration: InputDecoration(
                                  labelText: "Driver Name",
                                  // hintText: "",
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: const BorderSide(
                                      color: AppColors
                                          .primaryGreen, // Customize the outline color
                                    ),
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
                                ),
                              ),
                              const Vspace(16),
                              const Text("Driver Address"),
                              const Vspace(16),
                              TextField(
                                keyboardType: TextInputType.streetAddress,
                                cursorColor: AppColors.black,
                                controller: licenseaddress,
                                decoration: InputDecoration(
                                    labelText: "Driver Address",
                                    // hintText: "",
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors
                                            .primaryGreen, // Customize the outline color
                                      ),
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
                                    prefixIcon: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Icon(Icons.pin_drop),
                                    )),
                              ),
                              const Vspace(16),
                              const Text("Driver License Category"),
                              const Vspace(16),
                              DropdownButton<String>(
                                  isExpanded: true,
                                  items: <DropdownMenuItem<String>>[
                                    DropdownMenuItem<String>(
                                      value: 'MCWG',
                                      child: Text('MCWG'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'LMV',
                                      child: Text('LMV'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'HMV',
                                      child: Text('HMV'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'MGV',
                                      child: Text('MGV'),
                                    ),
                                    // <DropdownMenuItem<String>>(child: Text("Male"),value: 'Male'),
                                    // <DropdownMenuItem<String>>(child: Text("Female"),value: "Female"),
                                  ],
                                  value: licenseCategory,
                                  // isExpanded: true, // Optional: Makes the dropdown take the full width of its container

                                  onChanged: (value) {
                                    setState(() {
                                      licenseCategory = value!;
                                    });
                                  }),
                              const Vspace(16),
                              const Text("Gender"),
                              const Vspace(16),
                              DropdownButton<String>(
                                  isExpanded: true,
                                  items: <DropdownMenuItem<String>>[
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
                                  value: gender,
                                  // isExpanded: true, // Optional: Makes the dropdown take the full width of its container

                                  onChanged: (value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  }),
                              const Vspace(16),
                              const Text("Driving License Valid upto"),
                              const Vspace(16),
                              TextField(
                                  enabled: true,
                                  keyboardType: TextInputType.datetime,
                                  controller: dlvalid,
                                  // style: TextStyle(color: AppColors.primaryGreen),
                                  cursorColor: AppColors.black,
                                  onTap: () {
                                    // _requestFocus;
                                    onTapFunction2(context: context);
                                  },
                                  // inputFormatters: [],

                                  decoration: InputDecoration(
                                    labelText: "Valid upto",
                                    hintText: "02-05-2024",
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors
                                            .primaryGreen, // Customize the outline color
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
                              Vspace(16),
                              Row(children: [
                                if (dlverified)
                                  SvgPicture.asset("assets/icons/complete.svg",
                                      color: Colors.green),
                                if (!dlverified)
                                  SvgPicture.asset("assets/icons/pending.svg",
                                      color: const Color(0xff707070)),
                                const SizedBox(
                                    width:
                                        10), // Add some space between icon and text
                                Text(
                                  dlverified
                                      ? "Success"
                                      : "Verification pending",
                                  style: TextStyle(
                                    color: dlverified
                                        ? Colors.green
                                        : const Color(0xff707070),
                                  ),
                                ),
                              ]),
                              Vspace(8),
                              MaterialButton(
                                height: 48,
                                minWidth: double.infinity,
                                onPressed: () {
                                  dlVerificationFailed();
                                },
                                color: AppColors.primaryGreen,
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Save",
                                        style:
                                            TextStyle(color: AppColors.white),
                                      ),
                              ),
                              Vspace(8),
                            ],
                          ),
                        ),
                  Divider(),
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
                                      drivingLicenceFront
                                          .showImagePicker(context, () {
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
                                                drivingLicenceFront =
                                                    ImagePickerUtil();

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
                                      drivingLicenceBack
                                          .showImagePicker(context, () {
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
                                              drivingLicenceBack
                                                  .pickedImage()
                                                  .absolute,
                                              height: 150),
                                          Positioned(
                                            top: 2,
                                            right: 5,
                                            child: GestureDetector(
                                              onTap: () {
                                                // Handle cancel button press here
                                                drivingLicenceBack =
                                                    ImagePickerUtil();

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
                  const Vspace(8),
                  Divider(),
                  const Vspace(8),
                  const BigTitle(
                    bigTitle: "Vehicle Details",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  const Vspace(16),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRcindex = 0;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: selectedRcindex == 0
                                  ? AppColors.primaryGreen
                                  : AppColors.grey,
                            ),
                            height: 48,
                            child: Center(
                              child: Text(
                                "API",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width * 0.45,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedRcindex = 1;
                            });
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              color: selectedRcindex == 1
                                  ? AppColors.primaryGreen
                                  : AppColors.grey,
                            ),
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: Center(
                              child: Text(
                                "MANUAL",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  selectedRcindex == 0
                      ? Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Vspace(16),
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
                                    if (value.isNotEmpty &&
                                        value.length == 10) {
                                      //  postData();
                                    }
                                  }),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      if (rcverified)
                                        SvgPicture.asset(
                                            "assets/icons/complete.svg",
                                            color: Colors.green),
                                      if (!rcverified)
                                        SvgPicture.asset(
                                            "assets/icons/pending.svg",
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
                                                          : vehiclenamemodel
                                                              .toString())
                                                      : "Verification pending",
                                                  style: TextStyle(
                                                    color: rcverified
                                                        ? AppColors.primaryGreen
                                                        : const Color(
                                                            0xff707070),
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
                                            style: TextStyle(
                                                color: AppColors.white),
                                          ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Vspace(16),
                              const Text("Vehicle Number"),
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
                                    if (value.isNotEmpty &&
                                        value.length == 10) {
                                      //  postData();
                                    }
                                  }),
                              const Vspace(16),
                              const Text("Vehicle Fuel"),
                              const Vspace(16),
                              DropdownButton<String>(
                                  isExpanded: true,
                                  items: <DropdownMenuItem<String>>[
                                    DropdownMenuItem<String>(
                                      value: 'CNG',
                                      child: Text('CNG'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'PETROL',
                                      child: Text('PETROL'),
                                    ),
                                    DropdownMenuItem<String>(
                                      value: 'DIESEL',
                                      child: Text('DIESEL'),
                                    ),
                                    // <DropdownMenuItem<String>>(child: Text("Male"),value: 'Male'),
                                    // <DropdownMenuItem<String>>(child: Text("Female"),value: "Female"),
                                  ],
                                  value: vehiclefuel,
                                  // isExpanded: true, // Optional: Makes the dropdown take the full width of its container

                                  onChanged: (value) {
                                    setState(() {
                                      vehiclefuel = value!;
                                    });
                                  }),
                              const Vspace(16),
                              // TextField(
                              //   keyboardType: TextInputType.streetAddress,
                              //   cursorColor: AppColors.black,
                              //   controller: vehiclefuel,
                              //   decoration: InputDecoration(
                              //     labelText: "Vehicle Fuel",
                              //     // hintText: "",
                              //     contentPadding: const EdgeInsets.symmetric(
                              //         vertical: 12, horizontal: 14),
                              //     border: OutlineInputBorder(
                              //       borderRadius: BorderRadius.circular(4),
                              //       borderSide: const BorderSide(
                              //         color: AppColors
                              //             .primaryGreen, // Customize the outline color
                              //       ),
                              //     ),
                              //     focusedBorder: OutlineInputBorder(
                              //       borderRadius: BorderRadius.circular(4),
                              //       borderSide: const BorderSide(
                              //         color: AppColors
                              //             .primaryGreen, // Customize the focus outline color
                              //       ),
                              //     ),
                              //     focusColor: AppColors.primaryGreen,
                              //     fillColor: AppColors.primaryGreen,
                              //   ),
                              // ),
                              // const Vspace(16),
                              const Text("Vehicle Model"),
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
                                // enabled: widget.isEnabled,
                                keyboardType: TextInputType.text,
                                controller: vehicleMakermodel,

                                // style: TextStyle(color: AppColors.primaryGreen),
                                cursorColor: AppColors.black,
                                // maxLength: ,
                                textCapitalization:
                                    TextCapitalization.characters,
                                decoration: InputDecoration(
                                  labelText: "Vehicle Model",
                                  // hintText: "",
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: const BorderSide(
                                      color: AppColors
                                          .primaryGreen, // Customize the outline color
                                    ),
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
                                ),
                              ),
                              const Vspace(16),
                              const Text("RC Valid upto"),
                              const Vspace(16),
                              TextField(
                                  enabled: true,
                                  keyboardType: TextInputType.datetime,
                                  controller: rcvalid,
                                  // style: TextStyle(color: AppColors.primaryGreen),
                                  cursorColor: AppColors.black,
                                  onTap: () {
                                    // _requestFocus;
                                    onTapFunction3(context: context);
                                  },
                                  // inputFormatters: [],

                                  decoration: InputDecoration(
                                    labelText: "Valid upto",
                                    hintText: "02-05-2024",
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 14),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                        color: AppColors
                                            .primaryGreen, // Customize the outline color
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
                              Vspace(16),
                              Row(children: [
                                if (rcverified)
                                  SvgPicture.asset("assets/icons/complete.svg",
                                      color: Colors.green),
                                if (!rcverified)
                                  SvgPicture.asset("assets/icons/pending.svg",
                                      color: const Color(0xff707070)),
                                const SizedBox(
                                    width:
                                        10), // Add some space between icon and text
                                Text(
                                  rcverified
                                      ? "Success"
                                      : "Verification pending",
                                  style: TextStyle(
                                    color: rcverified
                                        ? Colors.green
                                        : const Color(0xff707070),
                                  ),
                                ),
                              ]),
                              Vspace(8),
                              MaterialButton(
                                height: 48,
                                minWidth: double.infinity,
                                onPressed: () {
                                  rcVerificationFailed();
                                },
                                color: AppColors.primaryGreen,
                                child: _loading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Save",
                                        style:
                                            TextStyle(color: AppColors.white),
                                      ),
                              ),
                              Vspace(8),
                            ],
                          ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          containerColor:
                              _vehicleDetailType == VehicleDetailType.hatchback
                                  ? AppColors.white
                                  : Colors.transparent,
                          borderColor:
                              _vehicleDetailType == VehicleDetailType.hatchback
                                  ? AppColors.primaryGreen
                                  : Colors.black12,
                          borderWidth: 1,
                          onTap: () {
                            setState(() {
                              _vehicleDetailType = VehicleDetailType.hatchback;
                            });
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  const BigTitle(
                    bigTitle: "Profile Photo",
                    fontSize: 13.999999046325684,
                    fontWeight: FontWeight.w500,
                  ),
                  driverPhoto.pickedImage().path.isNotEmpty
                      ? UploadedFileWidget(
                          name: driverPhoto.pickedImage().path.split('/').last,
                          removeImage: () {
                            driverPhoto = ImagePickerUtil();
                            setState(() {});
                          },
                          viewImage: () =>
                              viewImage(driverPhoto.pickedImage().absolute),
                        )
                      : const SizedBox.shrink(),
                  const Vspace(10),
                  driverPhoto.pickedImage().path.isNotEmpty
                      ? SizedBox.fromSize()
                      : UploadImageWidget(
                          onTap: () {
                            driverPhoto.showImagePicker(context, () {
                              setState(() {});
                            });
                          },
                          title: "Upload Profile Photo",
                        ),
                  const Vspace(41),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GestureDetector(
                      onTap: () {
                        validateAndSave();
                      },
                      child: const CustomButton(
                        text: "Register",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        )
      ]),
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

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 50,
        width: double.maxFinite,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(4)),
        child: TextWidget(
          text: text,
          color: AppColors.white,
        ));
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
