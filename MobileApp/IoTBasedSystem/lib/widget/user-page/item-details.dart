import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qldfyp1/widget/user-page/item-list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../myapp.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ItemDetail extends StatefulWidget {
  final String itemMngtId;

  const ItemDetail({required this.itemMngtId, Key? key}) : super(key: key);

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  String? qldId, roleId, username, fullName, imagePath;
  Map<String, dynamic>? itemDetails;
  bool isLoading = true;
  String? qrDataDelivery, qrDataRecipient, qrData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchItemDetails();
  }

  // Define key and IV here
  final encrypt.Key key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');  // Must be 32 bytes
  final encrypt.IV iv = encrypt.IV.fromLength(16);

  String encryptData(String data) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final iv = encrypt.IV.fromLength(16); // Generate a new IV
    final encrypted = encrypter.encrypt(data, iv: iv);
    return iv.base64 + encrypted.base64; // Prepend IV to encrypted data
  }

  Future<void> fetchItemDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://${MyApp.baseIpAddress}${MyApp.itemDetailsPath}?itemMngtId=${widget.itemMngtId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          itemDetails = json.decode(response.body);

          qrDataDelivery = 'qrCode=${itemDetails!["qrcode_delivery_id"]}&itemMngtId=${widget.itemMngtId}&itemSize=${itemDetails!["size_type"]}&roleId=${roleId}&lockerLocationId=${itemDetails!["locker_location_id"]}';
          qrDataRecipient = 'qrCode=${itemDetails!["qrcode_recipient_id"]}&itemMngtId=${widget.itemMngtId}&itemSize=${itemDetails!["size_type"]}&roleId=${roleId}&lockerLocationId=${itemDetails!["locker_location_id"]}';

          qrDataDelivery = encryptData('${qrDataDelivery}');
          qrDataRecipient = encryptData('${qrDataRecipient}');

          if (roleId == "2") {
            qrData = qrDataDelivery;
          } else if (roleId == "3") {
            qrData = qrDataRecipient;
          }

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
  }

  bool showImage = false; // State variable to control image visibility

  @override
  Widget build(BuildContext context) {
    String? itemDetailsDate;

    if (itemDetails != null) {
      if (roleId == '2') {
        itemDetailsDate = DateFormat('dd-MM-yyyy ::: HH:mm:ss').format(DateTime.parse(itemDetails!['register_date']));
      } else if (roleId == '3') {
        itemDetailsDate = DateFormat('dd-MM-yyyy ::: HH:mm:ss').format(DateTime.parse(itemDetails!['arrived_date']));
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFCFCFC),
        title: Text(
          'Item Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ItemList()),
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
              'Receipt Id- ${widget.itemMngtId}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.person, size: 20, color: Colors.blue[800]),
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
                    color: itemDetails!['status_name'] == 'Pending'
                        ? Colors.redAccent
                        : itemDetails!['status_name'] == 'Arrived'
                        ? Colors.orangeAccent
                        : itemDetails!['status_name'] == 'Picked'
                        ? Colors.green
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${itemDetails!['status_name']}',
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
            if (itemDetailsDate != null)
              Row(
                children: [
                  Icon(Icons.date_range, size: 20, color: Colors.blue[800]),
                  SizedBox(width: 8),
                  Text(
                    'Date\t\t\t\t\t\t\t\t\t: $itemDetailsDate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showImage = !showImage;
                      });
                    },
                    child: Text(showImage ? 'Hide QR Code' : 'Show QR Code'),
                  ),
                  SizedBox(height: 16),
                  if (showImage && qrData != null)
                    QrImageView(
                      data: qrData!, // Use the combined data string
                      version: QrVersions.auto,
                      size: 290.0,
                    ),
                ],
              ),
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
