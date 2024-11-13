// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class BroadcastPage extends StatefulWidget {
  final ChatService _chatService;

  const BroadcastPage(this._chatService, {super.key});

  @override
  BroadcastPageState createState() => BroadcastPageState();
}

class BroadcastPageState extends State<BroadcastPage> {
  final TextEditingController _messageController = TextEditingController();
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();

    // Load existing broadcast messages
   _loadMessages();
    // Listen for incoming messages
    widget._chatService.onMessageReceived = (message) {
      setState(() {
        _messages.add(message);
      });
    };
  }

  void _loadMessages() {
    setState(() {
      _messages = widget._chatService.getBroadcastMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Broadcast'), automaticallyImplyLeading: false,), 
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_messages[index]), // Display the message
              );
            },
          )),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Enter a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.blue,
                  onPressed: () {
                    // Send the message to the server
                    widget._chatService.sendBroadcastMessage(_messageController.text);
                    _messageController.clear(); // Clear the text field after sending
                  },
                  )
              ]
            )
            )
        ],
      ),
    );
  }
}