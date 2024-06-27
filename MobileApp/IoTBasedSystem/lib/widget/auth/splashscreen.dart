import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qldfyp1/widget/admin/qr-scan.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/user.dart';
import 'login.dart';
import '../user-page/dashboard.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? qldId, roleId, username, fullName, imagePath;

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      qldId = prefs.getString('qld_id');
      roleId = prefs.getString('roleId');
      username = prefs.getString('username');
      fullName = prefs.getString('fullName'); // Fetch the username
      imagePath = prefs.getString('imagePath');
    });

    print (roleId);

    if (qldId != null && qldId!.isNotEmpty) {
      // Navigate to Dashboard if user data exists
      if (roleId == "1") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else if(roleId == "2" || roleId == "3") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      }
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => Dashboard()),
      // );
    } else {
      // Navigate to LoginPage if user data does not exist
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 1),
      () async {
        await fetchUserData();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFC), // Set background color to #fcfcfc
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display your logo image here
            Image.asset(
              'assets/QLD-logo.jpg', // Replace with the path to your logo image
              width: 200, // Adjust the width as needed
              height: 200, // Adjust the height as needed
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
