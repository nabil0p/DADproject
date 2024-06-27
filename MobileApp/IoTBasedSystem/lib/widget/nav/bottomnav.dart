import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavCourier extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavCourier({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  _BottomNavCourierState createState() => _BottomNavCourierState();
}

class _BottomNavCourierState extends State<BottomNavCourier> {
  String? roleId;

  @override
  void initState() {
    super.initState();
    // Fetch roleId only if it hasn't been fetched yet
    if (roleId == null) {
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fetchedRoleId = prefs.getString('roleId');
    setState(() {
      roleId = fetchedRoleId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: [
        _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
        //_buildNavItem(icon: Icons.list, label: roleId == "2" ? 'Pending' : (roleId == "3" ? 'Arrived' : ''), index: 1),
        _buildNavItem(icon: Icons.list, label: 'Item', index: 1),
        _buildNavItem(icon: Icons.how_to_vote, label: 'Locations', index: 2),
        //_buildNavItem(icon: Icons.history, label: roleId == "2" ? 'Delivered' : (roleId == "3" ? 'Picked' : ''), index: 3),
        _buildNavItem(icon: Icons.history, label: 'History', index: 3),
        _buildNavItem(icon: Icons.people, label: 'Profile', index: 4),
      ],
      currentIndex: widget.currentIndex,
      onTap: widget.onItemTapped,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      iconSize: 24,
      selectedIconTheme: IconThemeData(size: 30),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    return BottomNavigationBarItem(
      icon: _buildIcon(icon, index == widget.currentIndex),
      label: label,
    );
  }

  Widget _buildIcon(IconData icon, bool isSelected) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: isSelected
          ? BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      )
          : null,
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.black,
      ),
    );
  }
}