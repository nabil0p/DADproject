import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qldfyp1/widget/admin/qr-update-delivery.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt;

import '../auth/navigation-utils.dart';
import '../myapp.dart';

class AdminPage extends StatefulWidget {
  final String location;
  final String locationId;

  AdminPage({required this.location, required this.locationId});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool isSending = false;
  Map<String, dynamic>? apiResponse;

  List<String>? data;
  String? qrCode, itemMngtId, roleId, lockerLocationId, itemSize;

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  final encrypt.Key key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1'); // Must be 32 bytes
  final encrypt.IV iv = encrypt.IV.fromLength(16);

  String decryptData(String encryptedData) {
    try {
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final ivBase64 = encryptedData.substring(0, 24); // Extract IV (24 characters for Base64)
      final cipherText = encryptedData.substring(24); // Extract the ciphertext
      final iv = encrypt.IV.fromBase64(ivBase64);
      final decrypted = encrypter.decrypt64(cipherText, iv: iv);
      return decrypted;
    } catch (e) {
      print('Error decrypting data: $e');
      showToast('Wrong QR code');
      return '';
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });

      // Pause the camera
      controller.pauseCamera();

      String decryptedData = decryptData(result!.code!);

      if (decryptedData.isEmpty) {
        controller.pauseCamera();
        return;
      }

      // Split the result data into qrCode, itemMngtId, and roleId
      List<String> data = decryptedData.split('&');
      if (data.length < 5) {
        showToast('Invalid QR code');
        controller.pauseCamera();
        return;
      }

      try {
        String qrCode = data[0].split('=')[1];
        String itemMngtId = data[1].split('=')[1];
        String itemSize = data[2].split('=')[1];
        String roleId = data[3].split('=')[1];
        String lockerLocationId = data[4].split('=')[1];

        print('qrCode: $qrCode, itemMngtId: $itemMngtId, itemSize: $itemSize, roleId: $roleId, lockerLocationId: $lockerLocationId');

        if (widget.locationId == lockerLocationId) {
          verifyItemIsExist(qrCode, itemMngtId, itemSize, roleId, lockerLocationId);
        } else {
          showToast("Sorry, you are at wrong Locker Location\nPlease Try Again");
        }
      } catch (e) {
        showToast('Invalid QR code format. Please Try Again');
      } finally {
        controller.pauseCamera();
      }
    });
  }

  Future<void> verifyItemIsExist(String? qrCode, String? itemMngtId, String? itemSize,
      String? roleId, String? lockerLocationId) async {
    if (qrCode == null || itemMngtId == null || itemSize == null || roleId == null ||
        lockerLocationId == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            'http://${MyApp.baseIpAddress}${MyApp
                .verifyItemPath}?qrCode=$qrCode&itemMngtId=$itemMngtId&itemSize=$itemSize&roleId=$roleId&lockerLocationId=$lockerLocationId'),
      );
      print('http://${MyApp.baseIpAddress}${MyApp.verifyItemPath}?qrCode=$qrCode&itemMngtId=$itemMngtId&itemSize=$itemSize&roleId=$roleId&lockerLocationId=$lockerLocationId');
      // Print the status code and the body of the response
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          apiResponse = json.decode(response.body);

          if (apiResponse != null) {
            if (apiResponse!['data'] == 'No Locker Available') {
              showToast('No Locker Size $itemSize is Available');
            } else if (apiResponse!['data'] == 'Success' && !isSending) {
              showToast('Verification successful');
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        UpdateLocker(
                            apiResponse!['locker_key'], roleId, itemMngtId, itemSize,
                            lockerLocationId, qrCode)),
              );
            } else if (apiResponse!['data'] == 'Failed') {
              showToast('Verification Not Successful');
            }
          } else {
            showToast('Invalid API response');
          }
        });
      } else {
        throw Exception('Failed to load report');
      }
    } catch (e) {
      print('Error fetching report: $e');
      showToast('Verification Not Successful');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void reset() {
    setState(() {
      result = null;
      apiResponse = null;
      isSending = false;
    });
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: reset,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (result != null)
                    Text('QrCode Scanned Successful')
                  else
                    Text('Scan The QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (isSending) CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: reset,
        child: Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
