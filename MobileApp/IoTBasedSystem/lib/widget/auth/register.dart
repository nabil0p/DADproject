import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../myapp.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController username = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController fullName = TextEditingController();
  TextEditingController emailAddress = TextEditingController();
  TextEditingController icNumber = TextEditingController();
  TextEditingController phoneNumber = TextEditingController();
  TextEditingController confirmPass = TextEditingController();


  Future register() async {
    if (username.text.isEmpty ||
        pass.text.isEmpty ||
        confirmPass.text.isEmpty ||
        fullName.text.isEmpty ||
        emailAddress.text.isEmpty ||
        icNumber.text.isEmpty ||
        phoneNumber.text.isEmpty) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Please fill in all the fields',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else if (pass.text != confirmPass.text) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Passwords did not match',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      var url = Uri.http(MyApp.baseIpAddress, MyApp.registerPath, {'q': '{http}'});

      try {
        var response = await http.post(url, body: {
          "username": username.text.toString(),
          "password": pass.text.toString(),
          "fullName": fullName.text.toString(),
          "emailAddress": emailAddress.text.toString(),
          "icNumber": icNumber.text.toString(),
          "phoneNumber": phoneNumber.text.toString(),
        });

        // Log the response details
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('Input: username= ${username.text.toString()}, '
            'password= ${pass.text.toString()}, '
            'fullName= ${fullName.text.toString()}, '
            'emailAddress= ${emailAddress.text.toString()}, '
            'icNumber= ${icNumber.text.toString()}, '
            'phoneNumber= ${phoneNumber.text.toString()}');

        var data = json.decode(response.body);

        switch (data) {
          case "Success":
            Fluttertoast.showToast(
              backgroundColor: Colors.black,
              textColor: Colors.white,
              msg: 'Registration Successful',
              toastLength: Toast.LENGTH_SHORT,
            );
            break;
          case "ErrorEmail":
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: 'Email already exists',
              toastLength: Toast.LENGTH_SHORT,
            );
            break;
          case "ErrorUsername":
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: 'Username already exists',
              toastLength: Toast.LENGTH_SHORT,
            );
            break;
          case "ErrorPhoneNumber":
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: 'Phone number already exists',
              toastLength: Toast.LENGTH_SHORT,
            );
            break;
          default:
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              textColor: Colors.white,
              msg: 'Invalid Input',
              toastLength: Toast.LENGTH_SHORT,
            );
        }
      } catch (e) {
        print('Error: $e');
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: 'An error occurred',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }



  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false; // Add a new boolean variable

  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // fullName.text = 'Nabil Aqmar';
    // icNumber.text = '012748263821';
    // emailAddress.text = 'nabil1234@gmail.com';
    // phoneNumber.text = '01276453658';
    // username.text = 'nabil1234';

    return Scaffold(
        body: SafeArea(
        child: Center(
        child: SingleChildScrollView(
        child: Form(
        key: _formKey,
        child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 0, 0), // Adjust X
                          child:Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextFormField(
                      controller: fullName,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      validator: (value){
                        if(value!.isEmpty){
                          return 'Invalid Input';
                        }else{
                          return null;
                        }
                      }
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: icNumber,
                      decoration: InputDecoration(
                        labelText: 'IC Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      validator: (value){
                        if(value!.isEmpty || RegExp(r'^[a-z A-Z]+$').hasMatch(value!) || !RegExp(r'^[0-9]+$').hasMatch(value!) || value.length<12 || value.length>12){
                          return 'IC Number must contains 12 digit without "-"';
                        }else{
                          return null;
                        }
                      }
                  ),
                ),
                const SizedBox(height: 15), // Space between IC Number and Email Address
                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextFormField( // Replaced Padding with TextFormField
                    controller: emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0), // Added border style
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    validator: (value){
                      // Asserts the value to non-null
                      if(!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value!)){
                        return 'Invalid format for email';
                      }
                    },
                  ),
                ),

                const SizedBox(height: 15), // Space between Email Address and Phone Number

                // Wrap the TextFormField with a SizedBox
                SizedBox(
                  width: screenWidth * 0.9, // Adjust width if needed
                  child: TextFormField(
                    controller: phoneNumber,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0), // Added border style
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    validator: (value){
                      if(value!.isEmpty || RegExp(r'^[a-z A-Z]+$').hasMatch(value!) || !RegExp(r'^[0-9]+$').hasMatch(value!) || value.length>11 || value.length<10){
                        return 'Invalid phone number';
                      }else{
                        return null;
                      }
                    },
                  ),
                ),

                const SizedBox(height: 15),

                // Wrap the TextFormField with a SizedBox
                SizedBox(
                  width: screenWidth * 0.9, // Adjust width if needed
                  child: TextFormField(
                    controller: username,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0), // Added border style
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    validator: (value){
                      if(value!.isEmpty || value.length<2){
                        return 'Username must has more than 3 character';
                      }else{
                        return null;
                      }
                    },
                  ),
                ),

                const SizedBox(height: 15), // Space between Username and Password

                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextFormField(
                    controller: pass,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0), // Added border style
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
                        ),
                      ),
                    ),
                      validator: (value) {
                        if (value!.isEmpty ||
                            !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_-]).+$')
                                .hasMatch(value) ||
                            value.length < 6) {
                          return 'Password must contain at least one lowercase letter, one uppercase letter, one number, one special character, and be at least 6 characters long';
                        } else {
                          return null;
                        }
                      }
                  ),
                ),

                const SizedBox(height: 15),
                SizedBox(
                  width: screenWidth * 0.9,
                  child: TextFormField(
                    controller: confirmPass,
                    obscureText: !isConfirmPasswordVisible, // Use the new variable
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0), // Added border style
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            isConfirmPasswordVisible =
                            !isConfirmPasswordVisible;
                          });
                        },
                        child: Icon(
                          isConfirmPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(width: 10),
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ), // Add some space between the checkbox and the text
                    Text(
                      'Agree with terms and conditions',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                isChecked
                    ? SizedBox.shrink() // Hide error message if checkbox is checked
                    : const Padding(
                  padding: EdgeInsets.only(right: 90),
                  child: Text(
                    'Please agree with terms and conditions',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: screenWidth * 0.88,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Check if form data is valid
                        if(_formKey.currentState!.validate()){
                          register();
                        }
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
                          'Register',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),),
    );
  }
}