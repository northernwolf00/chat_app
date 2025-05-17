import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/screens/contact_screen.dart';

import 'home_screen.dart'; // Chat Screen


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;


  void switchToChats() {
    setState(() {
      _currentIndex = 0;
    });
  }
  final List<Widget> _screens = [
    const HomeScreen(),     // Chat
    const ContactsScreen(), // Contacts
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items:  [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'chat'.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: 'contacts'.tr(),
          ),
        ],
      ),
    );
  }
}
