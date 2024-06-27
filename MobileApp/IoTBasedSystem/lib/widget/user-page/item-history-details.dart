import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../myapp.dart';
import 'package:http/http.dart' as http;

import 'item-history.dart';

class ItemHistoryDetail extends StatefulWidget {
  final String itemMngtId;

  const ItemHistoryDetail({required this.itemMngtId, Key? key}) : super(key: key);

  @override
  _ItemHistoryDetailState createState() => _ItemHistoryDetailState();
}

class _ItemHistoryDetailState extends State<ItemHistoryDetail> {
  String? qldId, roleId, username, fullName, imagePath;
  Map<String, dynamic>? itemDetails;
  bool isLoading = true;
  String? statusAoD;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchItemDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://${MyApp.baseIpAddress}${MyApp.itemHistoryDetailsPath}?itemMngtId=${widget.itemMngtId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          itemDetails = json.decode(response.body);

          statusAoD = itemDetails!['status_name'];


          if (roleId == "2" && statusAoD == 'Arrived'){
            statusAoD = 'Delivered';
          }

          print('roleId: $roleId'); // Debugging line
          print('statusAoD: $statusAoD'); // Debugging line


          isLoading = false;
        });
      } else {
        throw Exception('Failed to load item details');
      }
    } catch (e) {
      print('Error fetching item details: $e');
      setState(() {
        isLoading = false;
      });
    }
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

    fetchItemDetails();
  }

  @override
  Widget build(BuildContext context) {
    String? itemDetailsDate;

    if (itemDetails != null) {
      if (roleId == '2') {
        itemDetailsDate = DateFormat('dd-MM-yyyy ::: HH:mm:ss').format(
            DateTime.parse(itemDetails!['arrived_date']));
      }
      if (roleId == '3') {
        itemDetailsDate = DateFormat('dd-MM-yyyy ::: HH:mm:ss').format(
            DateTime.parse(itemDetails!['pickup_date']));
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFCFCFC),
        title: Text('Item History Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ItemHistory()),
            );
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: itemDetails != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipt - ${widget.itemMngtId}',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, size: 20, color: Colors.blue[800],),
                SizedBox(width: 8),
                Text(
                  'Sender\t\t\t\t: ${itemDetails!['item_from']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 20, color: Colors.blue[800]),
                SizedBox(width: 8),
                Text(
                  'Location\t: ${itemDetails!['location_name']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.format_size, size: 20, color: Colors.blue[800]),
                SizedBox(width: 8),
                Text(
                  'Size\t\t\t\t\t\t\t\t\t: ${itemDetails!['size_type']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info, size: 20, color: Colors.blue[800]),
                SizedBox(width: 8),
                Text(
                  'Status\t\t\t\t\t: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusAoD == 'Arrived'
                        ? Colors.green
                        : statusAoD == 'Delivered'
                        ? Colors.green
                        : statusAoD == 'Picked'
                        ? Colors.green
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${statusAoD}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.date_range, size: 20, color: Colors.blue[800]),
                SizedBox(width: 8),
                Text(
                  'Date\t\t\t\t\t\t\t\t: $itemDetailsDate',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // Add more details as needed
          ],
        )
            : Center(
          child: Text(
            'No item details available',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
