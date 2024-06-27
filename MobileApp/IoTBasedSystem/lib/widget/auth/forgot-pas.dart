import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../myapp.dart';

class SecurityQuestions extends StatefulWidget {
  const SecurityQuestions({Key? key}) : super(key: key);

  @override
  _SecurityQuestionsState createState() => _SecurityQuestionsState();
}

class _SecurityQuestionsState extends State<SecurityQuestions> {
  TextEditingController answer1 = TextEditingController();
  TextEditingController answer2 = TextEditingController();
  TextEditingController email = TextEditingController();


  Future<void> verifySecurityQuestions() async {
    String answer1Text = answer1.text;
    String answer2Text = answer2.text;
    String emailText = email.text;

    // Validate that both answers are not empty
    if (answer1Text.isEmpty || answer2Text.isEmpty || emailText.isEmpty) {
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Please fill in both security answers',
        toastLength: Toast.LENGTH_SHORT,
      );
      return;
    }

    // Add your server endpoint for verification
    var url = Uri.http(MyApp.baseIpAddress, MyApp.itemListPath, {'q': '{http}'});

    try {
      var response = await http.post(
        url,
        body: {
          "emailAddress" : emailText.toString(),
          "answer1": answer1Text.toString(),
          "answer2": answer2Text.toString(),
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data['verified']) {
          // If answers are correct and linked, show a dialog or navigate to a new page
          showUsernameDialog(data['username']);
        } else {
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: 'Incorrect answers. Please try again.',
            toastLength: Toast.LENGTH_SHORT,
          );
        }
      } else {
        // Handle server error
        print('Server error: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network or other errors
      print('Error: $error');
    }

  }

  void showUsernameDialog(String username) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verification Successful'),
          content: Text('Are you $username?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('No'),
            ),
            // TextButton(
            //   onPressed: () {
            //     // Perform the necessary action if the answer is 'Yes'
            //     // For example, navigate to another page
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ForgotPasswordPage(username: username),
            //       ),
            //     );
            //   },
            //   child: Text('Yes'),
            // ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 50.0),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Security Question',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Please fill in the fields to verify your identity',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Email ',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black87, // Specify the text color here
                    ),
                  ),
                  TextField(
                    controller: email,
                  ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: TextField(
                  //         controller: email,
                  //         decoration: InputDecoration(
                  //           hintText: 'Enter your email',
                  //         ),
                  //       ),
                  //     ),
                  //     InkWell(
                  //       onTap: () {
                  //         //verifyEmail();
                  //       },
                  //       // Customize the color as needed
                  //         child: Text(
                  //           'Verify Email ',
                  //           style: TextStyle(
                  //             color: Colors.black,
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //
                  //     ),
                  //   ],
                  // ),
                  SizedBox(height: 20,),
                  Text(
                    'Question 1',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black87, // Specify the text color here
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'What city were you born in?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54, // Specify the text color here
                    ),
                  ),
                  TextField(
                    controller: answer1,
                  ),
                ],
              ),
            ),
            //const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question 2',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.black87, // Specify the text color here
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'In what city or town did your parents meet?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54, // Specify the text color here
                    ),
                  ),
                  TextField(
                    controller: answer2,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                verifySecurityQuestions();
              },
              style: ElevatedButton.styleFrom(
                fixedSize: Size(340, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text('Verify', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}