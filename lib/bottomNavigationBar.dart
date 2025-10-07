import 'package:flutter/material.dart';
import 'package:personal_application/Diary/diaryScreen.dart';
import 'package:personal_application/Weather/weatherScreen.dart';
import 'package:personal_application/To-Do/to_do_screen.dart';
import 'package:personal_application/logout/logout.dart';

class BottomNav extends StatefulWidget {
  static const String id = "BottomNav";
  @override
  _BottomNav createState() => _BottomNav();
}

class _BottomNav extends State<BottomNav> {
  int _selectedIndex = 0;
  DateTime? _lastBackPressed;

  final List<Widget> _pages = [
    Diaryscreen(),
    Weatherscreen(),
    ToDoScreen(),
    Logout(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<bool> _onWillPop() async {
    final now = DateTime.now();
    const maxDuration = Duration(seconds: 2);
    final isWarning =
        _lastBackPressed == null ||
        now.difference(_lastBackPressed!) > maxDuration;

    if (isWarning) {
      _lastBackPressed = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Press back again to exit the app',
            style: TextStyle(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.black87,
        ),
      );

      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
              icon: _buildBoxIcon(Icons.cloud, 1),
              label: "Diary",
            ),
            BottomNavigationBarItem(
              icon: _buildBoxIcon(Icons.border_color, 2),
              label: "Weather",
            ),
            BottomNavigationBarItem(
              icon: _buildBoxIcon(Icons.person, 3),
              label: "Logout",
            ),
          ],
        ),
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
