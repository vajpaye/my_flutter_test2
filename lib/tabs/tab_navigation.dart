import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'favorites_tab.dart';
import 'settings_tab.dart';
import 'profile_tab.dart';
import 'more_tab.dart';

class TabNavigation extends StatefulWidget {
  @override
  _TabNavigationState createState() => _TabNavigationState();
}

class _TabNavigationState extends State<TabNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    HomeTab(),
    FavoritesTab(),
    SettingsTab(),
    ProfileTab(),
    MoreTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Buddy'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Review',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black.withOpacity(0.6),
        onTap: _onItemTapped,
      ),
    );
  }
}
