import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../admin/select-location.dart';
import 'register.dart';
import '../myapp.dart';
import 'forgot-pas.dart';
import '../admin/qr-scan.dart';
import '../user-page/dashboard.dart';
import '../../model/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController user = TextEditingController();
  TextEditingController pass = TextEditingController();


  Future login() async {
    if (user.text.isEmpty || pass.text.isEmpty) {
      Fluttertoast.showToast(
        backgroundColor: Colors.black,
        textColor: Colors.white,
        msg: 'Invalid Input',
        toastLength: Toast.LENGTH_SHORT,
      );
      return; // Exit the function to prevent further execution
    }

    var url = Uri.http(MyApp.baseIpAddress, MyApp.loginPath, {'q': '{http}'});

    var response = await http.post(url, body: {
      "username": user.text,
      "password": pass.text,
    });

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      Map<String, dynamic> data = json.decode(response.body);

      if (data["status"] == "ErrorPass") {
        Fluttertoast.showToast(
          msg: 'Incorrect Password or Username',
          backgroundColor: Colors.black,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
      } else if (data["status"] == "ErrorUsername") {
        Fluttertoast.showToast(
          msg: 'Username Does Not Exist',
          backgroundColor: Colors.black,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );
      } else if (data["status"] == "Success") {
        Fluttertoast.showToast(
          msg: 'Login Successful',
          backgroundColor: Colors.black,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_SHORT,
        );


        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', user.text);

        String? userId = data['qld_id']; // Check if 'qld_id' exists in data
        if (userId != null) {
          prefs.setString('qld_id', userId);
          OneSignal.login(userId.toString());

          if (data.containsKey('image')) {
            String imageBase64 = data['image'];
            List<int> imageBytes = base64.decode(imageBase64);

            String imagePath = await _saveImageLocally(imageBytes, 2);
            prefs.setString('imagePath', imagePath);
          }

          prefs.setString('icNumber', data['icNumber']);
          prefs.setString('fullName', data['fullName']);
          prefs.setString('phoneNumber', data['phoneNumber']);
          prefs.setString('emailAddress', data['emailAddress']);
          // Assuming role_id should be saved as a string
          prefs.setString('roleId', data['role_id'].toString());

          // Access 'role_id' and store it in a local variable as a string
          String roleId = data['role_id'].toString();


          if (roleId == '1') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminLocation()),
            );
          } else if (roleId == '2' || roleId == '3' ) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard()),
            );
          }
           else {
            print('Unknown roleId: $roleId');
          }
        } else {
          print('qld_id not found in response');
        }
      } else {
        print('Status is not "Success"');
      }
    } else {
      Fluttertoast.showToast(
        msg: 'No Internet Connection',
        //'HTTP request failed with status: ${response.statusCode}',
        backgroundColor: Colors.black,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<String> _saveImageLocally(List<int> imageBytes, int userId) async {
    // Save the image in the app's cache directory with a filename based on the user's ID
    String cacheDirPath = (await getTemporaryDirectory()).path;
    String imagePath = '$cacheDirPath/profile_image_$userId.jpg';

    // Write the image bytes to the file
    await File(imagePath).writeAsBytes(imageBytes);

    return imagePath;
  }

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                width: screenWidth * 0.9,
                child: TextField(
                  controller: user,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: screenWidth * 0.9,
                child: TextField(
                  controller: pass,
                  obscureText: !isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      child: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SecurityQuestions(),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Forgot password?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: screenWidth * 0.88,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      login();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.blue, // Set the background color here
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Sign Up',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Register(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}