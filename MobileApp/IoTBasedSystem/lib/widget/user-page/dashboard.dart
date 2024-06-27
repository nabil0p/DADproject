import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../model/user-report.dart';
import '../auth/navigation-utils.dart';
import '../myapp.dart';
import '../nav/bottomnav.dart';
import '../nav/topnav.dart';
import 'profile.dart';
import 'item-list.dart';
import 'item-history.dart';
import 'locker-location.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String? qldId, roleId, username, fullName, imagePath;
  int _selectedIndex = 0;
  UserReport? userReport;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  //TOAST FUNCTION
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      qldId = prefs.getString('qld_id');
      roleId = prefs.getString('roleId');
      username = prefs.getString('username');
      fullName = prefs.getString('fullName');
      imagePath = prefs.getString('imagePath');
    });

    fetchItemDetails();
  }

  Future<void> fetchItemDetails() async {
    try {
      String url =
          'http://${MyApp.baseIpAddress}${MyApp.userReportPath}?qldId=$qldId&roleId=$roleId';
      // print("URL: $url");

      final response = await http.get(Uri.parse(url));
      // print('Response status code: ${response.statusCode}');
      // print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          var userReportJson = json.decode(response.body);
          userReport = UserReport.fromJson(userReportJson);
        });
      } else {
        throw Exception('Failed to load report');
      }
    } catch (e) {
      print('Error fetching report: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Use Navigator to navigate to different pages based on index
    switch (index) {
      case 1:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ItemList(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                LockerLocation(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ItemHistory(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      case 4:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => Profile(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
      default:
        // Do nothing for case 0 as it is the Dashboard
        break;
    }
  }

  Future<void> updateCourierDetails(String? qldId, String? available) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://${MyApp.baseIpAddress}${MyApp.updateCourierDetailsPath}'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'qldId': qldId, 'available': available},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var dataResponse = json.decode(response.body);

        if (dataResponse != null && dataResponse['data'] == 'Success') {
          String availability = dataResponse['availability'];
          String dataAvailable;

          if (availability == "1") {
            dataAvailable = "Available";
          } else if (availability == "0") {
            dataAvailable = "Not Available";
          } else {
            dataAvailable = "Unknown";
          }

          showToast('Availability Updated: $dataAvailable');
          fetchItemDetails(); // Call this function to refresh item details
        } else {
          print('Failed response: $dataResponse');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => NavigationUtils.onWillPop(context),
      child: Scaffold(
        appBar: TopBar(
          username: username ?? 'loading',
          fullName: fullName ?? 'loading',
          imagePath: imagePath ?? 'null',
          onSettingsPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
          onProfilePressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset(
                    'assets/QLD-logo.jpg',
                    height: 180,
                  ),
                ),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: roleId == "2" ? Colors.red[400] : roleId == "3" ? Colors.blue[400] : Colors.grey,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Welcome, ${roleId == "2" ? 'Courier' : roleId == "3" ? 'Receiver' : ''}.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoCard(
                      title: roleId == "2" ? 'Pending' : 'Arrived',
                      count: roleId == "2"
                          ? userReport?.cPendingCount
                          : userReport?.rArrivedCount,
                      icon: roleId == "2"
                          ? Icons.hourglass_empty_rounded
                          : Icons.location_on_rounded,
                    ),
                    SizedBox(width: 8),
                    _buildInfoCard(
                      title: roleId == "2" ? 'Delivered' : 'Picked',
                      count: roleId == "2"
                          ? userReport?.cDeliveredCount
                          : userReport?.rPickedCount,
                      icon: Icons.check_circle_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (roleId == "2")
                  ElevatedButton(
                    onPressed: () {
                      updateCourierDetails(qldId, userReport?.cAvailable);
                      print('Button pressed for roleId 2');
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: getButtonColor(userReport?.cAvailable),
                      // Background color
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30.0), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12), // Button padding
                    ),
                    child: Text(
                      'My Status: ${userReport?.cAvailable == "0" ? 'Not Available' : 'Available'}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavCourier(
          currentIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }

  Color getButtonColor(String? availability) {
    if (availability == "0") {
      return Colors.red[400]!;
    } else {
      return Colors.blue[400]!;
    }
  }

  Widget _buildInfoCard(
      {required String title, required int? count, required IconData icon}) {
    return Expanded(
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.blue[400],
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Text(
                    count?.toString() ?? '0',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
