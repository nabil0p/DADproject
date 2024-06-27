import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../auth/navigation-utils.dart';
import '../myapp.dart';
import 'button/action_button.dart';

class UpdateLocker extends StatefulWidget {
  final String lockerKey;
  final String roleId;
  final String itemMngtId;
  final String itemSize;
  final String lockerLocationId;
  final String qrCode;


  UpdateLocker(this.lockerKey, this.roleId, this.itemMngtId, this.itemSize,
      this.lockerLocationId, this.qrCode);

  @override
  _UpdateLockerState createState() => _UpdateLockerState();
}

class _UpdateLockerState extends State<UpdateLocker> {
  bool isSending = false;
  Map<String, dynamic>? dataResponse;

  String? closeLockerId;
  String? courierLockerId;
  String? selectedLocker;

  //TOAST FUNCTION
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  //BLUETOOTH FUNCTION
  final _bluetooth = FlutterBluetoothSerial.instance;
  bool _bluetoothState = false;
  bool _isConnecting = false;
  BluetoothConnection? _connection;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _deviceConnected;
  String _receivedData = "";

  void _getDevices() async {
    var res = await _bluetooth.getBondedDevices();
    setState(() => _devices = res);
  }

  void _receiveData() {
    _connection?.input?.listen((event) {
      String receivedString = ascii.decode(event);
      List<String> parts = receivedString.split('=');

      setState(() {
        _receivedData += receivedString + '\n';
      });

      if (parts.length == 2 && parts[0] == 'Close') {
        String lockerId = parts[1].trim();

        print('Closing locker to match: $lockerId');
        closeAvailableLocker(lockerId, widget.roleId);

      }
    });
  }

  void _sendData(String data) {
    if (_connection?.isConnected ?? false) {
      _connection?.output.add(ascii.encode(data));
    }
  }

  void _autoConnect() async {
    try {
      _getDevices();
      await Future.delayed(
          Duration(seconds: 2)); // Wait for devices to be fetched

      for (final device in _devices) {
        if (device.name == "HC-05") {
          setState(() => _isConnecting = true);

          _connection = await BluetoothConnection.toAddress(device.address);
          _deviceConnected = device;
          _devices = [];
          _isConnecting = false;

          _receiveData();

          setState(() {});
          break;
        }
      }
    } catch (e) {
      print(e);
      setState(() => _isConnecting = false);
    }
  }

  //INITSTATE FUNCTION
  @override
  void initState() {
    super.initState();
    //Choosing The role to get Selected Locker
    if (widget.roleId == "2") {
      findLockerAvailable();
    }
    if (widget.roleId == "3") {
      selectedLocker = widget.lockerKey;
    }

    //CONNECT TO LOCKER
    _bluetooth.state.then((state) {
      setState(() => _bluetoothState = state.isEnabled);
      if (_bluetoothState) {
        _autoConnect();
      }
    });

    _bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BluetoothState.STATE_OFF:
          setState(() => _bluetoothState = false);
          break;
        case BluetoothState.STATE_ON:
          setState(() => _bluetoothState = true);
          _autoConnect();
          break;
      }
    });
  }

  //FIND LOCKER FOR COURIER
  Future<void> findLockerAvailable() async {
    setState(() {
      isSending = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.baseIpAddress}${MyApp.selectLockerPath}'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'lockerLocationId': widget.lockerLocationId,
          'itemSize': widget.itemSize
        },
      );

      if (response.statusCode == 200) {
        dataResponse = json.decode(response.body);

        closeLockerId = dataResponse!['lockerId'];
        courierLockerId = dataResponse!['lockerId'];

        if (dataResponse != null && dataResponse!['data'] == 'Success') {
          showToast('Locker Is waiting to connect and then open');
          print('Locker ID: ${courierLockerId}');
          selectedLocker = courierLockerId;
        } else {
          showToast('Unexpected response: ${courierLockerId}');
          print('Unexpected response: ${courierLockerId}');
        }

        if (dataResponse != null &&
            dataResponse!['data'] == 'All Locker Is Full') {
          showToast('All Locker Is Full');
        }

        // Handle success
      } else {
        showToast('Failed to connect');
        // Handle failure
      }
    } catch (e) {
      // Handle error
      showToast('Other Failed to connect');
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  Future<void> updateLockerLock(String? lockerId) async {
    setState(() {
      isSending = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.baseIpAddress}${MyApp.updateLockerLockPath}'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'qrRecipient': widget.lockerKey,
          'itemMngtId': widget.itemMngtId,
          'lockerLocationId': widget.lockerLocationId,
          'qrCode': widget.qrCode,
          'lockerId': lockerId,
        },
      );

      if (response.statusCode == 200) {
        final dataResponse = json.decode(response.body);

        if (dataResponse != null) {
          final String? lockerIdResponse = dataResponse['lockerId'];
          final String? responseData = dataResponse['data'];

          if (lockerIdResponse != null) {
            closeLockerId = lockerIdResponse;
            courierLockerId = lockerIdResponse;
          }

          if (responseData == 'Success') {
            showToast('Open The Locker');
            print('Locker ID: $courierLockerId');

          } else if (responseData == 'Locker is Already Open') {
            showToast('Locker is Already Open');

          } else if (responseData == 'Opening The Locker Again') {
            showToast('Opening The Locker Again...');
            print('Locker ID: $courierLockerId');

          } else if (responseData == 'All Locker Is Full') {
            showToast('All Locker Is Full');

          } else {
            showToast('Unexpected response: $responseData');
            print('Unexpected response: $responseData');

          }

        } else {
          showToast('Invalid response format');
        }
      } else {
        showToast('Failed to connect');
      }
    } catch (e) {
      showToast('Failed to connect: $e');
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  Future<void> removeLockerLock() async {
    setState(() {
      isSending = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://${MyApp.baseIpAddress}${MyApp.removeLockerLockPath}'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'lockerKey': widget.lockerKey,
          'itemMngtId': widget.itemMngtId,
          'lockerLocationId': widget.lockerLocationId,
          'qrCode': widget.qrCode
        },
      );

      if (response.statusCode == 200) {
        dataResponse = json.decode(response.body);

        closeLockerId = widget.lockerKey;
        selectedLocker = widget.lockerKey;

        if (dataResponse != null && dataResponse!['data'] == 'Success') {
          showToast('Locker successfully updated.');
        } else {
          showToast('Failed to update locker: ${dataResponse!['data']}');
        }
      } else {
        // Handle failure
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        showToast('Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
      print('Caught error new eror: $e');
      showToast('Caught error: $e');
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  // END DELIVERY API FUNCTION

  // // OPEN LOCKER FUNCTION
  // Future<void> openAvailableLocker(String? lockerId, String? roleId) async {
  //   // open Process; wait until it close;
  // }

  // CLOSE LOCKER FUNCTION
  Future<void> closeAvailableLocker(String? lockerId, String? roleId) async {
    print('Closing Locker ID: $lockerId');
    print('roleId: $roleId');
    print('location: ${widget.lockerLocationId}');
    setState(() {
      isSending = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://${MyApp.baseIpAddress}${MyApp.updateLockerClosePath}'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'lockerId': lockerId,
          'roleId': roleId,
          'lockerLocationId': widget.lockerLocationId
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var dataResponse = json.decode(response.body);

        if (dataResponse != null && dataResponse['data'] == 'Success') {

          if (closeLockerId == lockerId) {
            showToast('Closing The Locker ...');
            _connection?.finish();
            setState(() => _deviceConnected = null);
            Navigator.pop(context);

          } else {
            showToast('Locker not match');
          }

        } else {
          print('Failed response: $dataResponse');
        }
      } else {
        print('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isSending = false;
      });
    }
  }

  //INTERFACE
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => NavigationUtils.onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFCFCFC),
          title: Text('Update Locker', style: TextStyle(fontWeight: FontWeight.bold)),
          // leading: IconButton(
          //   icon: Icon(Icons.arrow_back),
          //   onPressed: () async {
          //     await _connection?.finish();
          //     setState(() => _deviceConnected = null);
          //
          //     Navigator.pop(context);
          //   },
          // ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              SizedBox(height: 30),
              Text(
                'Open Locker: ${selectedLocker ?? 'N/A'}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              _infoDevice(),
              Expanded(child: _listDevices()),
              if (_connection?.isConnected ?? false) _buttons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoDevice() {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.black12,
          title: Text(
            _connection?.isConnected ?? false
                ? "Device Connected"
                : "Wait to connect to the device...",
          ),
          // trailing: _connection?.isConnected ?? false
          //     ? TextButton(
          //   onPressed: () async {
          //     // Preventing the user from disconnecting
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       SnackBar(
          //         content: Text("You cannot disconnect from the device."),
          //       ),
          //     );
          //   },
          //   child: const Text("Disconnect"),
          // )
              //: null,
        ),
      ],
    );
  }

  Widget _listDevices() {
    return _isConnecting
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      child: Container(
        color: Colors.grey.shade100,
        child: Column(
          children: [
            for (final device in _devices)
              ListTile(
                //title: Text(device.name ?? device.address),
                title: Text(
                  "Finding the device...",
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buttons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
      color: Colors.black12,
      child: Column(
        children: [
          const Text('Locker Controller', style: TextStyle(fontSize: 18.0)),
          const SizedBox(height: 16.0),
          Row(
            children: [
              Expanded(
                child: ActionButton(
                  text: "OPEN THE LOCKER",
                  color: Colors.green,
                  onTap: () {
                    String? selectedLocker;
                    if (widget.roleId == "2") {
                      updateLockerLock(courierLockerId);
                      selectedLocker = courierLockerId;
                    }

                    if (widget.roleId == "3") {
                      removeLockerLock();
                      selectedLocker = widget.lockerKey;
                    }

                    if (selectedLocker != null) {
                      print("Locker ID: $selectedLocker");
                      _sendData(selectedLocker); // sendData to open locker
                    } else {
                      print("Locker ID is not available.");
                    }
                  },
                ),
              ),
              const SizedBox(width: 8.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _receivedDataDisplay() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.black12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data Receive: ', style: TextStyle(fontSize: 18.0)),
          const SizedBox(height: 8.0),
          Text(_receivedData, style: const TextStyle(fontSize: 16.0)),
        ],
      ),
    );
  }
}
