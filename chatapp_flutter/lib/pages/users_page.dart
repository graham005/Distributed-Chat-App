// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class UsersPage extends StatefulWidget {
  final ChatService _chatService;

  const UsersPage(this._chatService, {super.key});

  @override
  UsersPageState createState() => UsersPageState();
}

class UsersPageState extends State<UsersPage> {

  @override
  void initState() {
    super.initState();

    // Listen for updates to the list of users
    widget._chatService.onUsersUpdated = (users) {
      setState(() {
         // Update the list of users
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    List<String> users = widget._chatService.users;
    return Scaffold(
      appBar: AppBar(
        title: Text('Connected Users'),
        automaticallyImplyLeading: false),
      body: users.isEmpty ? Center(child: Text('No users connected')) : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index]),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/privateChat',
                arguments: {
                  'chatService': widget._chatService,
                  'recipientUsername': users[index]
                }
              );
            }
          );
        }
      ),
    );
  }
}
