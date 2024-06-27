import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qldfyp1/widget/admin/qr-scan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/locker-location.dart';
import '../auth/login.dart';
import '../auth/navigation-utils.dart';
import '../myapp.dart';

class AdminLocation extends StatefulWidget {
  @override
  State<AdminLocation> createState() => _AdminLocationState();
}

class _AdminLocationState extends State<AdminLocation> {
  String? qldId, roleId, username, fullName, imagePath;
  String searchQuery = '';
  List<LocationList> locationList = [];
  bool isLoading = true;
  String? lockerAddress, lockerId;

  @override
  void initState() {
    super.initState();
    fetchLockerLocation();
    _requestPermission();
  }

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

  void _requestPermission() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
  }

  void handleButtonPress(String location, String locationId) {
    print('Button pressed for lockerId: $locationId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPage(location: location, locationId: locationId),
      ),
    );
  }

  Future<void> fetchLockerLocation() async {
    try {
      String url = 'http://${MyApp.baseIpAddress}${MyApp.lockerLocationPath}';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final String responseBody = response.body.trim();

        if (responseBody.isNotEmpty && responseBody != '0 results') {
          final List<dynamic> jsonData = json.decode(responseBody);

          setState(() {
            locationList = jsonData.map((location) => LocationList.fromJson(location)).toList();

            isLoading = false;
          });
        } else {
          print('Server responded with "0 results" or empty response body.');
          setState(() {
            locationList = [];
            isLoading = false;
          });
        }
      } else {
        print('Failed to load item data. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching item data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => NavigationUtils.onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFCFCFC),
          title: const Text(
            'Select Your Lockers Location',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _logout(context);
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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search Location",
                        prefixIcon: Icon(Icons.search),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          borderSide: BorderSide(
                              color: Colors.grey),
                        ),
                      ),
                      style: TextStyle(
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: locationList.length,
                itemBuilder: (context, index) {
                  final location = locationList[index];

                  if (location.locationName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                      location.locationAddress.toLowerCase().contains(searchQuery.toLowerCase())) {
                    return Card(
                      color: Colors.white,
                      elevation: 8,
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        tileColor: Colors.white,
                        title: Text(
                          location.locationName,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          location.locationAddress,
                          style: TextStyle(color: Colors.black87),
                        ),
                        leading: _buildImage(location.locationImage),
                        trailing: ElevatedButton(
                          onPressed: () {
                            handleButtonPress(location.locationName, location.locationId);
                          },
                          child: Text(
                            "Direction",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String base64Image) {
    try {
      final decodedBytes = base64Decode(base64Image);
      return Image.memory(decodedBytes, width: 50, height: 50, fit: BoxFit.cover);
    } catch (e) {
      print('Error decoding image: $e');
      return Icon(Icons.broken_image, size: 50);
    }
  }
}