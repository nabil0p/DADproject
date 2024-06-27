import 'package:flutter/material.dart';
import '../model/user.dart';
import 'auth/login.dart';
import 'auth/splashscreen.dart';

import 'user-page/dashboard.dart';
import 'user-page/settings.dart';
import 'user-page/profile.dart';

class MyApp extends StatelessWidget {


  //API XAMPP HTDOC
  // static final String baseIpAddress = "10.131.76.29";
  static final String baseIpAddress = "192.168.0.140:8080";

  //API XAMPP HTDOC
  // static final String loginPath = "/fyp/qldProject/api/app-login.php";
  // static final String registerPath = "/fyp/qldProject/api/app-register.php";
  // static final String updateProfilePath = "/fyp/qldProject/api/app-upProfile.php";
  // static final String updateImagePath = "/fyp/qldProject/api/app-upImage.php";
  // static final String itemListPath = "/fyp/qldProject/api/app-viItemList.php";
  // static final String itemHistoryListPath = "/fyp/qldProject/api/app-viItemHistoryList.php";
  // static final String itemDetailsPath = "/fyp/qldProject/api/app-viItemDetails.php";
  // static final String itemHistoryDetailsPath = "/fyp/qldProject/api/app-viItemHistoryDetails.php";
  // static final String userReportPath = "/fyp/qldProject/api/app-viUserReport.php";
  // static final String lockerLocationPath = "/fyp/qldProject/api/app-viLockerLocation.php";
  // static final String verifyItemPath  = "/fyp/qldProject/api/app-verifyItem.php";
  // static final String updateLockerLockPath  = "/fyp/qldProject/api/app-upLockerLock.php";
  // static final String removeLockerLockPath  = "/fyp/qldProject/api/app-deLockerLock.php";
  // static final String updateLockerClosePath  = "/fyp/qldProject/api/app-upLockerClose.php";
  // static final String updateCourierDetailsPath  = "/fyp/qldProject/api/app-upCourierDetails.php";
  // static final String selectLockerPath  = "/fyp/qldProject/api/app-seLocker.php";
  // static final String updatePasswordPath  = "/fyp/qldProject/api/app-upPassword.php";

  //API XAMPP HTDOC Hosting Code but Use IP address
  static final String loginPath = "/fyp/qldProject1/api/app-login.php";
  static final String registerPath = "/fyp/qldProject1/api/app-register.php";
  static final String updateProfilePath = "/fyp/qldProject1/api/app-upProfile.php";
  static final String updateImagePath = "/fyp/qldProject1/api/app-upImage.php";
  static final String itemListPath = "/fyp/qldProject1/api/app-viItemList.php";
  static final String itemHistoryListPath = "/fyp/qldProject1/api/app-viItemHistoryList.php";
  static final String itemDetailsPath = "/fyp/qldProject1/api/app-viItemDetails.php";
  static final String itemHistoryDetailsPath = "/fyp/qldProject1/api/app-viItemHistoryDetails.php";
  static final String userReportPath = "/fyp/qldProject1/api/app-viUserReport.php";
  static final String lockerLocationPath = "/fyp/qldProject1/api/app-viLockerLocation.php";
  static final String verifyItemPath  = "/fyp/qldProject1/api/app-verifyItem.php";
  static final String updateLockerLockPath  = "/fyp/qldProject1/api/app-upLockerLock.php";
  static final String removeLockerLockPath  = "/fyp/qldProject1/api/app-deLockerLock.php";
  static final String updateLockerClosePath  = "/fyp/qldProject1/api/app-upLockerClose.php";
  static final String updateCourierDetailsPath  = "/fyp/qldProject1/api/app-upCourierDetails.php";
  static final String selectLockerPath  = "/fyp/qldProject1/api/app-seLocker.php";
  static final String updatePasswordPath  = "/fyp/qldProject1/api/app-upPassword.php";

  // //API quicklocker-delivery.000webhostapp.com
  // static final String baseIpAddress = "quicklocker-delivery.000webhostapp.com";
  // //API quicklocker-delivery.000webhostapp.com
  // static final String loginPath = "/api/app-login.php";
  // static final String registerPath = "/api/app-register.php";
  // static final String updateProfilePath = "/api/app-upProfile.php";
  // static final String updateImagePath = "/api/app-upImage.php";
  // static final String itemListPath = "/api/app-viItemList.php";
  // static final String itemHistoryListPath = "/api/app-viItemHistoryList.php";
  // static final String itemDetailsPath = "/api/app-viItemDetails.php";
  // static final String itemHistoryDetailsPath = "/api/app-viItemHistoryDetails.php";
  // static final String userReportPath = "/api/app-viUserReport.php";
  // static final String lockerLocationPath = "/api/app-viLockerLocation.php";
  // static final String verifyItemPath  = "/api/app-verifyItem.php";
  // static final String updateLockerLockPath  = "/api/app-upLockerLock.php";
  // static final String removeLockerLockPath  = "/api/app-deLockerLock.php";
  // static final String updateLockerClosePath  = "/api/app-upLockerClose.php";
  // static final String updateCourierDetailsPath  = "/api/app-upCourierDetails.php";
  // static final String selectLockerPath  = "/api/app-seLocker.php";
  // static final String updatePasswordPath  = "/api/app-upPassword.php";





  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final darkColorForLightTheme = 0xff2196f3;
    final lightColorForDarkTheme = 0xff03DAC5;
    var isDark = true;
    var primaryColorHex = (isDark ? darkColorForLightTheme : darkColorForLightTheme);
    var primaryColor = Color(primaryColorHex);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QuickLocker-Delivery',
      theme: ThemeData.light().copyWith(
        primaryColor: primaryColor,
        brightness: Brightness.light,
        backgroundColor: const Color(0xFFE5E5E5),
        dividerColor: Colors.white54,
        colorScheme: ColorScheme.light(primary: primaryColor),
      ),
      home: SplashScreen(),
      routes: {
        '/dashboard': (context) => Dashboard(),
        '/settings': (context) => Settings(),
        '/profile': (context) => Profile(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}