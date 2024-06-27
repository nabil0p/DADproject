import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/user.dart';
import '../auth/navigation-utils.dart';
import '../myapp.dart';
import '../nav/topnav.dart';
import '../nav/bottomnav.dart';
import 'item-details.dart';
import 'profile.dart';
import 'item-history.dart';
import 'dashboard.dart';
import 'locker-location.dart';
import 'package:http/http.dart' as http;
import '../../model/item.dart';

class ItemList extends StatefulWidget {
  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  String? qldId, roleId, username, fullName, imagePath;
  String searchQuery = '';
  int _selectedIndex = 1;
  late User data;
  List<Item> itemData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      qldId = prefs.getString('qld_id');
      roleId = prefs.getString('roleId');
      username = prefs.getString('username');
      fullName = prefs.getString('fullName');
      imagePath = prefs.getString('imagePath'); // Fetch the username
    });
    fetchItems();
  }

  void handleButtonPress(String itemMngtId) {
    print('Button pressed for itemMngtId: $itemMngtId');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetail(itemMngtId: itemMngtId),
      ),
    );
  }

  Future<void> fetchItems() async {
    try {
      String url =
          'http://${MyApp.baseIpAddress}${MyApp.itemListPath}?qldId=${qldId ?? ""}&roleId=${roleId ?? ""}';
      //print("URL: $url");

      final response = await http.get(Uri.parse(url));
      //print('Response status code: ${response.statusCode}');
      //print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final String responseBody = response.body.trim();

        if (responseBody.isNotEmpty && responseBody != '0 results') {
          final List<dynamic> jsonData = json.decode(responseBody);

          setState(() {
            itemData = jsonData.map((item) => Item.fromJson(item)).toList();

            // if (roleId == '2') {
            //   itemData.sort((a, b) => a.registerDate.compareTo(b.registerDate));
            // }
            // if (roleId == '3') {
            //   itemData.sort((a, b) => a.arrivedDate.compareTo(b.arrivedDate));
            // }
            isLoading = false;
          });
        } else {
          print('Server responded with "0 results" or empty response body.');
          setState(() {
            itemData = [];
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
        // Navigate to Dashboard page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                Dashboard(),
            transitionDuration:
                Duration.zero, // Set transition duration to zero
          ),
        );
        break;
      case 1:
        // Already Navigate to ItemList page
        break;
      case 2:
        // Navigate to Locker Location page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                LockerLocation(),
            transitionDuration:
                Duration.zero, // Set transition duration to zero
          ),
        );
        break;
      case 3:
        // Navigate to ItemHistory page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                ItemHistory(),
            transitionDuration:
                Duration.zero, // Set transition duration to zero
          ),
        );
        break;
      case 4:
        // Navigate to ItemList page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => Profile(),
            transitionDuration:
                Duration.zero, // Set transition duration to zero
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
          title: Text(roleId == "2" ? 'Pending List' : (roleId == "3" ? 'Arrived List' : ''),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),),
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
        body:

        Column(
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
                        hintText: "Search Item",
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
                              color:
                                  Colors.grey), // Change to your desired color
                        ),
                      ),
                      style: TextStyle(
                          color: Colors.black), // Change to your desired color
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: itemData.length,
                      itemBuilder: (context, index) {
                        final item = itemData[index];

                        // Convert date to string in 'yyyy-mm-dd' format
                        String itemDate='', itemTime='';
                        if (roleId == '2') {
                          itemDate =
                          '${item.registerDate.day.toString().padLeft(2, '0')}-${item
                              .registerDate.month.toString().padLeft(2, '0')}-${item
                              .registerDate.year}';

                          itemTime = '${item.registerDate.hour.toString().padLeft(2, '0')}:${item
                            .registerDate.minute.toString().padLeft(2, '0')}:${item
                            .registerDate.second.toString().padLeft(2, '0')}';
                        }

                        if (roleId == '3') {
                          itemDate =
                          '${item.arrivedDate.day.toString().padLeft(2, '0')}-${item
                              .arrivedDate.month.toString().padLeft(2, '0')}-${item
                              .arrivedDate.year}';

                          itemTime = '${item.arrivedDate.hour.toString().padLeft(2, '0')}:${item
                              .arrivedDate.minute.toString().padLeft(2, '0')}:${item
                              .arrivedDate.second.toString().padLeft(2, '0')}';

                        }

                        // Convert both searchQuery and item data to lower case
                        if (item.itemMngtId
                              .toLowerCase()
                              .contains(searchQuery.toLowerCase()) ||
                            item.itemFrom
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()) ||
                            item.locationName
                                .toLowerCase()
                                .contains(searchQuery.toLowerCase()) ||
                            itemDate.contains(searchQuery)) {
                          return Card(
                            color: Colors
                                .white, // Change background color to white
                            elevation: 8,
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                              child: ListTile(
                                tileColor: Colors.white,
                                title: Text(
                                  item.itemMngtId,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors
                                          .blue,
                                      fontWeight: FontWeight.bold), // Change text color to blue
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("From: " + item.itemFrom,
                                        style: TextStyle(color: Colors.black87)),
                                    Text(item.locationName,
                                        style: TextStyle(color: Colors.black87)),
                                    // Change text color to grey
                                    Text(
                                        itemDate +
                                            ' :: ' +
                                            itemTime,
                                        style: TextStyle(color: Colors.black87)),
                                    // Change text color to grey
                                  ],
                                ),
                                trailing: ElevatedButton(
                                  onPressed: () {
                                    // Handle button press
                                    handleButtonPress(item.itemMngtId);
                                  },
                                  child: Text(
                                    roleId == "2" ? 'Deliver' : 'Pick Now',
                                    // Change text based on roleId
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            18), // Change text color to white
                                  ), // Change text color to white
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    // Change button color to blue // Add padding
                                    textStyle: TextStyle(
                                      // Text style
                                      fontSize: 20, // Increase font size
                                      fontWeight:
                                          FontWeight.bold, // Make text bold
                                    ),
                                  ),
                                ),
                              ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              'No item details available',
                              style: TextStyle(fontSize: 18, color: Colors.red),
                            ),
                          ); // Return an empty container if the item does not match the search query
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
}
