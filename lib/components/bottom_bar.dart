import 'package:servicetracker_app/pages/home.dart';

import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final String currentPage;

  const BottomNavBar({Key? key, required this.currentPage}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  void _onItemTapped(String page) {
    if (page == widget.currentPage) return;
    // Only check authentication for the friends page
    switch (page) {
      case 'home':
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(currentPage: 'home')),
        );
        break;
      case 'service':
        break;
      case 'profile':
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        );
        break;
      case 'setting':
        break;
    }
  }

  List<BottomNavigationBarItem> _buildBottomNavigationBarItems() {
    return [
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: "Home",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.report),
        label: "Service",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.notifications),
        label: "Profile",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.people_alt_rounded),
        label: "Setting",
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getSelectedIndex(widget.currentPage),
      onTap: (index) {
        String page = _getPageFromIndex(index);
        _onItemTapped(page);
      },
      selectedItemColor: Colors.orange, // Set your selected color here
      unselectedItemColor: Colors.grey, // Set your unselected color here
      showSelectedLabels: true, // Show label for selected item
      showUnselectedLabels: true, // Show label for unselected items
      items: _buildBottomNavigationBarItems(),
    );
  }

  int _getSelectedIndex(String page) {
    switch (page) {
      case 'home':
        return 0;
      case 'service':
        return 1;
      case 'profile':
        return 2;
      case 'settings':
        return 3;

      default:
        return 0;
    }
  }

  String _getPageFromIndex(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'service';
      case 2:
        return 'profile';
      case 3:
        return 'settings';
      default:
        return 'home';
    }
  }
}
