// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

import 'pages/broadcast_page.dart';
import 'pages/users_page.dart';
import 'services/chat_service.dart';

class HomePage extends StatefulWidget {
  final ChatService _chatService;

  const HomePage(this._chatService, {super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      BroadcastPage(widget._chatService),
      UsersPage(widget._chatService),
    ];
  }

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
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Public Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), 
            label: 'Private Chat',
          )
        ],
        currentIndex: _selectedIndex, // The index of the selected item
        selectedItemColor: Colors.blue, // Customize the selected item color
        onTap: _onItemTapped, // Handle item tap
      ),
    );
  }
}