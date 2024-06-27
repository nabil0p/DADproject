import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart'; // Add this import

class NavigationUtils {
  static int _backPressCounter = 0;
  static Timer? _backPressTimer;

  static Future<bool> onWillPop(BuildContext context) async {
    if (_backPressCounter == 0) {
      _backPressCounter++;
      _backPressTimer = Timer(const Duration(seconds: 2), () {
        _backPressCounter = 0;
      });
      Fluttertoast.showToast(
        msg: 'Press back again to close the app',
        backgroundColor: Colors.black,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
      return false;
    } else {
      _backPressTimer?.cancel();
      _closeApp();
      return true;
    }
  }

  static void _closeApp() {
    SystemNavigator.pop(); // This closes the app
  }
}


// static void _logout(BuildContext context) {
//   SharedPreferences.getInstance().then((prefs) {
//     prefs.clear();
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => LoginPage()),
//           (route) => false,
//     );
//   });
// }