import 'package:flutter/material.dart';

class HelpSupport extends StatelessWidget {
  final List<HelpItem> helpItems = [
    HelpItem(
      title: 'How to use the app?',
      details: '''
1. Download the QuickLocker-Delivery app from the Google Play Store.
2. Open the app and sign up using your email and personal details.
3. After registration, you will receive a unique QLD_ID.
4. When purchasing items online, include your QLD_ID in the address details.
5. You will receive a notification when your parcel is delivered to the locker.
6. Open the app, navigate to your parcel details, and generate a QR code for retrieval.
7. Go to the locker location, scan the QR code at the locker to open it, and collect your parcel.
      ''',
      //imageUrl: 'assets/QLD-logo.jpg',
    ),
    HelpItem(
      title: 'How to reset password?',
      details: '''
1. Open the QuickLocker-Delivery app.
2. Go to the login screen and tap on "Forgot Password?".
3. Enter your registered email address.
4. Check your email for a password reset link.
5. Follow the instructions in the email to reset your password.
      ''',
      //imageUrl: 'assets/QLD-logo.jpg',
    ),
    HelpItem(
      title: 'How to contact support?',
      details: '''
You can contact support by:
1. Opening the QuickLocker-Delivery app.
2. Going to the "Help & Support" section.
3. Selecting "Contact Support".
4. Filling out the form with your issue and submitting it.
5. You will receive a response from our support team via email.
      ''',
      //imageUrl: 'assets/QLD-logo.jpg',
    ),
    HelpItem(
      title: 'How to register as a courier?',
      details: '''
1. Visit the administration office to apply for a courier position.
2. Fill out the necessary forms and provide any required identification or documentation.
3. Once approved, you will receive login credentials for the QuickLocker-Delivery Courier app.
4. Download the QuickLocker-Delivery Courier app from the Google Play Store.
5. Log in using the credentials provided by the administration office.
6. Follow the instructions in the app to start delivering parcels.
      ''',
      //imageUrl: 'assets/QLD-logo.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFCFCFC),
        title: Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigate back when back button is pressed
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: helpItems.map((item) {
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ExpansionTile(
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (item.imageUrl != null)
                        //   Center(
                        //     child: SizedBox(
                        //       height: 100, // Adjust height as needed
                        //       child: Image.asset(item.imageUrl!), // Display the image
                        //     ),
                        //   ),
                        //SizedBox(height: 10), // Add some space between the image and text
                        Text(
                          item.details,
                          style: TextStyle(
                            height: 1.5,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class HelpItem {
  final String title;
  final String details;
  //final String? imageUrl;

  HelpItem({required this.title, required this.details});//this.imageUrl
}
