import 'dart:io';
import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String username, fullName;
  final String imagePath;
  final VoidCallback onSettingsPressed;
  final VoidCallback onProfilePressed;

  const TopBar({super.key,
    required this.username,
    required this.fullName,
    required this.imagePath,
    required this.onSettingsPressed,
    required this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AppBar(
        backgroundColor: Color(0xFFFCFCFC),
        leading: GestureDetector(
          onTap: onProfilePressed,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2), // Shadow color
                    spreadRadius: 2, // Spread radius
                    blurRadius: 3, // Blur radius
                    offset: Offset(0, 1), // Offset of the shadow
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 75,
                backgroundImage: imagePath.isNotEmpty && File(imagePath).existsSync()
                    ? FileImage(File(imagePath))
                    : AssetImage('assets/profile.jpg') as ImageProvider,
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello!',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold), // Adjusted font size for username
            ),
            Text(
              username[0].toUpperCase() + username.substring(1),
              style: TextStyle(fontSize: 16.0), // Adjusted font size for full name
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: onSettingsPressed,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}