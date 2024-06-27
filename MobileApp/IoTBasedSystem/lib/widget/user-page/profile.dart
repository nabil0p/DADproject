import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/user.dart';
import '../auth/navigation-utils.dart';
import '../myapp.dart';
import '../nav/bottomnav.dart';
import 'item-list.dart';
import 'item-history.dart';
import 'dashboard.dart';
import 'locker-location.dart';

class Profile extends StatefulWidget {

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  late User data;

  @override
  void initState() {
    super.initState();

    _loadUserData();
  }

  int _selectedIndex = 4;

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
            pageBuilder: (context, animation, secondaryAnimation) => Dashboard(),
            transitionDuration: Duration.zero, // Set transition duration to zero
          ),
        );
        break;
      case 1:
      // Navigate to ItemList page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ItemList(),
            transitionDuration: Duration.zero, // Set transition duration to zero
          ),
        );
        break;
      case 2:
      // Navigate to locker location page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => LockerLocation(),
            transitionDuration: Duration.zero, // Set transition duration to zero
          ),
        );
        break;
      case 3:
      // Navigate to ItemHistory page
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => ItemHistory(),
            transitionDuration: Duration.zero, // Set transition duration to zero
          ),
        );
      case 4:
      // No need to navigate when index is 4 (Profile page)
      default:
      // Do nothing
    }
  }

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController = TextEditingController();
  late TextEditingController _emailAddressController = TextEditingController();
  late TextEditingController _phoneNumberController = TextEditingController();
  late TextEditingController _icNumberController = TextEditingController();


  String _qldId = '';
  String _roleId = '';
  String _username = '';
  String _fullName = '';
  String _imagePath = '';
  String _emailAddress = '';
  String _icNumber = '';
  String _phoneNumber = '';

  bool _isEditing = false;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;


  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _qldId = prefs.getString('qld_id') ?? 'qld';
      _roleId = prefs.getString('roleId') ?? 'none';
      _username = prefs.getString('username') ?? 'Username';
      _fullName = prefs.getString('fullName') ?? 'Full Name';
      _imagePath = prefs.getString('imagePath') ?? 'null';
      _emailAddress = prefs.getString('emailAddress') ?? 'mail@mail.com';
      _icNumber = prefs.getString('icNumber') ?? '012345678912';
      _phoneNumber = prefs.getString('phoneNumber') ?? '012345678912';

      // Initialize text controllers with fetched data
      _fullNameController = TextEditingController(text: _fullName);
      _emailAddressController = TextEditingController(text: _emailAddress);
      _phoneNumberController = TextEditingController(text: _phoneNumber);
      _icNumberController = TextEditingController(text: _icNumber);

      // Load image file if image path exists
      if (_imagePath != 'null') {
        _imageFile = File(_imagePath);
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailAddressController.dispose();
    _phoneNumberController.dispose();
    _icNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', _fullNameController.text);
    await prefs.setString('emailAddress', _emailAddressController.text);
    await prefs.setString('phoneNumber', _phoneNumberController.text);
    await prefs.setString('icNumber', _icNumberController.text);
    if (_imageFile != null) {
      await prefs.setString('imagePath', _imageFile!.path);
    }
  }

  Future<void> saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Save the profile data
    } else {
      Fluttertoast.showToast(
        msg: 'Please correct the errors in the form.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT,
      );
    }

    if (_fullNameController.text.isEmpty ||
        _emailAddressController.text.isEmpty ||
        _icNumberController.text.isEmpty ||
        _phoneNumberController.text.isEmpty) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Please fill in all the fields',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      // Save profile data to shared preferences
      await _saveUserData();

      // Assuming you have a URL for updating profile data
      var url = Uri.http(MyApp.baseIpAddress, MyApp.updateProfilePath, {'q': '{http}'});

      var response = await http.post(url, body: {
        "full_name": _fullNameController.text.toString(),
        "email_address": _emailAddressController.text.toString(),
        "ic_number": _icNumberController.text.toString(),
        "phone_number": _phoneNumberController.text.toString(),
        "username": _username,
      });

      // Check the response status code
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        switch (data) {
          case "Success":
            Fluttertoast.showToast(
              backgroundColor: Colors.black,
              textColor: Colors.white,
              msg: 'Profile updated successfully',
              toastLength: Toast.LENGTH_SHORT,
            );
            break;
          default:
            Fluttertoast.showToast(
              backgroundColor: Colors.black,
              textColor: Colors.white,
              msg: 'Invalid Input',
              toastLength: Toast.LENGTH_SHORT,
            );
        }
      } else {
        // Failed to update profile
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: 'Failed to update profile',
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Assuming you have a URL for uploading the image to the API
      var url = Uri.http(MyApp.baseIpAddress, MyApp.updateImagePath, {'q': '{http}'});

      // Create a multipart request
      var request = http.MultipartRequest('POST', url);

      // Attach the username to the request body
      request.fields['username'] = _username;

      // Attach the image file to the request
      request.files.add(await http.MultipartFile.fromPath('image', pickedFile.path));

      // Send the request and wait for the response
      var response = await request.send();

      // Check the response status code
      if (response.statusCode == 200) {
        // Read the response body
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);

        await _saveUserData();

        // Check the response data
        switch (data) {
          case "Success":
            Fluttertoast.showToast(
              backgroundColor: Colors.black,
              textColor: Colors.white,
              msg: 'Image update successfully',
              toastLength: Toast.LENGTH_SHORT,
            );
            break;
          default:
            Fluttertoast.showToast(
              backgroundColor: Colors.black,
              textColor: Colors.white,
              msg: 'Invalid Input',
              toastLength: Toast.LENGTH_SHORT,
            );
        }
      }else {
        // Image update failed
        String errorMessage = '';
        switch (response.statusCode) {
          case 400:
            Fluttertoast.showToast(
              backgroundColor: Colors.black,
              textColor: Colors.white,
              msg: 'No Internet Connection',
              toastLength: Toast.LENGTH_SHORT,
            );
            break;
          case 401:
            errorMessage = 'Unauthorized. Please login again.';
            break;
          case 404:
            errorMessage = 'Server not found. Please try again later.';
            break;
          case 500:
            errorMessage = 'Internal server error. Please try again later.';
            break;
          default:
            errorMessage = 'Failed to update image. Please try again later.';
            break;
        }
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => NavigationUtils.onWillPop(context), // Use the utility method
    child: Scaffold(
        resizeToAvoidBottomInset: true, // Set to true to automatically resize the body when the keyboard appears
        appBar: AppBar(
          backgroundColor: Color(0xFFFCFCFC),
          title: Text('Profile',
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
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 8),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              spreadRadius: 3,
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 75,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : AssetImage('assets/profile.jpg') as ImageProvider,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32, // Adjust width as needed
                          height: 32, // Adjust height as needed
                          decoration: BoxDecoration(
                            color: Colors.white, // Adjust opacity here (0.5 for 50% opacity)
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 3,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            iconSize: 18, // Adjust icon size as needed
                            icon: Icon(Icons.edit),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 26),
                Center(
                  child: Text(
                    'QLD ID: $_qldId',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 12),
                      _buildProfileField('Full Name', _fullNameController, _validateFullName),
                      _buildProfileField('Email Address', _emailAddressController, _validateEmail),
                      _buildProfileField('Phone Number', _phoneNumberController, _validatePhoneNumber),
                      _buildProfileField('IC Number', _icNumberController, _validateIcNumber),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () async {
                                if (_isEditing) {
                                  if (_formKey.currentState!.validate()) {
                                    await saveProfile();
                                    setState(() {
                                      _isEditing = false; // Set _isEditing to false after saving profile
                                    });
                                  }
                                } else {
                                  setState(() {
                                    if (_formKey.currentState!.validate()) {
                                      _isEditing = true; // Set _isEditing to true if form is valid

                                      // Show a SnackBar with a hint
                                      Fluttertoast.showToast(
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        msg: 'Tap the field to edit',
                                        toastLength: Toast.LENGTH_SHORT,
                                      );
                                    }
                                  });
                                }
                              },
                              icon: _isEditing ? Icon(Icons.save) : Icon(Icons.edit),
                            ),
                          ),
                        ],
                      ),
                    ],
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

  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full Name is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email Address is required';
    }
    // Regular expression for validating email address
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone Number is required';
    }
    // Regular expression for validating phone number (10 or 11 digits)
    if (!RegExp(r'^\d{10,11}$').hasMatch(value)) {
      return 'Enter a valid phone number (10 or 11 digits)';
    }
    return null;
  }

  String? _validateIcNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'IC Number is required';
    }
    if (!RegExp(r'^\d{12}$').hasMatch(value)) {
      return 'Enter a valid Ic Number (12 digits)';
    }
    return null;
  }

  Widget _buildProfileField(String label, TextEditingController controller, String? Function(String?) validator) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        readOnly: !_isEditing,
        decoration: InputDecoration(
          hintText: label,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          alignLabelWithHint: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0), // Added border style
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(15.0),
          ),
          prefixIcon: Icon(_getIconForLabel(label)),
        ),
        validator: validator,
      ),
    );
  }
  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Full Name':
        return Icons.person;
      case 'Email Address':
        return Icons.email;
      case 'Phone Number':
        return Icons.phone;
      case 'IC Number':
        return Icons.credit_card;
      default:
        return Icons.info;
    }
  }
}