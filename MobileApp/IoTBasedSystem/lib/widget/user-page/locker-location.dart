import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/locker-location.dart';
import '../auth/navigation-utils.dart';
import '../myapp.dart';
import '../nav/bottomnav.dart';
import 'dashboard.dart';
import 'item-history.dart';
import 'item-list.dart';
import 'profile.dart';
import 'map-location.dart';

class LockerLocation extends StatefulWidget {
  @override
  State<LockerLocation> createState() => _LockerLocationState();
}

class _LockerLocationState extends State<LockerLocation> {
  String? qldId, roleId, username, fullName, imagePath;
  String searchQuery = '';
  int _selectedIndex = 2;
  List<LocationList> locationList = [];
  bool isLoading = true;
  String? lockerAddress;

  @override
  void initState() {
    super.initState();
    fetchLockerLocation();
  }

  void handleButtonPress(String address, String lockerId) {
    print('Button pressed for lockerId: $lockerId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocation(address: address),
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

            // Assuming lockerAddress should be assigned from the first item in locationList
            if (locationList.isNotEmpty) {
              lockerAddress = locationList.first.locationAddress;
            }

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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Use Navigator to navigate to different pages based on index
    switch (index) {
      case 0:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => Dashboard(),
            transitionDuration: Duration.zero,
          ),
        );
        break;
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
      // Already on this page
        break;
      case 3:
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ItemHistory(),
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
      // Do nothing
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
            'Lockers Location',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/settings');
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
                            handleButtonPress(location.locationAddress, location.locationId);
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
            ),
          ],
        ),
        bottomNavigationBar: BottomNavCourier(
          currentIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
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