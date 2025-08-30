import 'package:flutter/material.dart';
import 'package:personal_application/Diary/diaryScreen.dart';

class BottomNav extends StatefulWidget {
  static const String id = "BottomNav";
  @override
  _BottomNav createState() => _BottomNav();
}

class _BottomNav extends State<BottomNav> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    Diaryscreen(),
    Center(child: Text("Diary Page", style: TextStyle(fontSize: 24))),
    Center(child: Text("Weather Page", style: TextStyle(fontSize: 24))),
    Center(child: Text("Logout Page", style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.lightBlue[300],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: _buildBoxIcon(Icons.book, 0),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _buildBoxIcon(Icons.book, 1),
            label: "Diary",
          ),
          BottomNavigationBarItem(
            icon: _buildBoxIcon(Icons.cloud, 2),
            label: "Weather",
          ),
          BottomNavigationBarItem(
            icon: _buildBoxIcon(Icons.person, 3),
            label: "Logout",
          ),
        ],
      ),
    );
  }

  Widget _buildBoxIcon(IconData icon, int index) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        color: _selectedIndex == index ? Colors.black12 : Colors.transparent,
      ),
      padding: EdgeInsets.all(6),
      child: Icon(icon, color: Colors.black),
    );
  }
}
