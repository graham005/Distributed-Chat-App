// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class PrivateChatPage extends StatefulWidget {
  final ChatService _chatService;
  final String recipientUsername;

  const PrivateChatPage(this._chatService, this.recipientUsername, {super.key});

  @override
  PrivateChatPageState createState() => PrivateChatPageState();
}

class PrivateChatPageState extends State<PrivateChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    widget._chatService.onMessageReceived = (String message) {
      setState(() {
        _messages.add("From ${widget.recipientUsername}: $message");
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Private Chat with ${widget.recipientUsername}')),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index])
                );
              },
            )
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
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
                    widget._chatService.sendPrivateMessage(
                      widget.recipientUsername, 
                      _messageController.text,
                      );
                      setState(() {
                        _messages.add("To ${widget.recipientUsername}: ${_messageController.text}");
                      });
                    _messageController.clear();
                  }
                )
              ]
            )
            )
        ],
      )
    );
  }
}