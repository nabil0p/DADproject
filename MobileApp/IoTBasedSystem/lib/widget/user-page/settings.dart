import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qldfyp1/widget/auth/change-password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login.dart'; // Import the LoginPage if not already imported
import 'package:fluttertoast/fluttertoast.dart';

import 'help-support.dart';

class Settings extends StatelessWidget {
  static void _logout(BuildContext context) {
    SharedPreferences.getInstance().then((prefs) async {
      // Clear shared preferences
      await prefs.clear();

      // Get the cache directory
      Directory cacheDir = await getTemporaryDirectory();

      // Delete all files in the cache directory
      if (cacheDir.existsSync()) {
        cacheDir.deleteSync(recursive: true);
      }

      // Clear image cache
      PaintingBinding.instance?.imageCache?.clear();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFCFCFC),
        title: Text('Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when back button is pressed
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.lock),
              title: Text('Change Password'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePassword()),
                );
                // Handle change password
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpSupport()),
                );
                // Handle help & support
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle help & support
                _logout(context);
                // Show toast message indicating successful logout
                Fluttertoast.showToast(
                  msg: "Logout Successful",
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}