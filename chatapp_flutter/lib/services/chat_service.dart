// ignore_for_file: avoid_print

import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
//import 'dart:convert';

class ChatService {
  late WebSocketChannel _channel;
  final String _server1 = "ws://127.0.0.1:8000"; // WebSocket URL for server 1
  final String _server2 = "ws://127.0.0.1:8001"; // WebSocket URL for server 2
  late String _username;

  Function(String message) onMessageReceived = (message) {};
  Function(List<String> users) onUsersUpdated = (users) {};
  Function(String status) onLoginResult = (status) {};
  Function(String status) onRegisterResult = (status) {};
  Function(String sender, String message) onPrivateMessageReceived = (sender, message) {};
  final List<String> _broadcastMessages = [];
  List<String> _users = [];

  List<String> get users => _users;

  List<String> getBroadcastMessages() {
    return _broadcastMessages;
  }

  Future<void> connectToServer() async {
    try {
      _channel = HtmlWebSocketChannel.connect(_server1);
      print("Connected to server 1"); 
    } catch (e) {
      print("Failed to connect to server 1, trying server 2...");
     try {
      _channel = HtmlWebSocketChannel.connect(_server2);
      print("Connected to server 2 at $_server2");
    } catch (e) {
      print("Failed to connect to server 2 at $_server2. Error: $e");
      return; // Exit if both connections fail
    }
    }

    //Listen for incoming messages
    _channel.stream.listen((data) {
      String message = data.toString();
      print("Message received: $message");
      if (message.startsWith("USERLIST:")) {
        // Extract the list of users from the message
        var users = message.substring(9).split(",").map((user) => user.trim()).toList(); // Ensure you correctly slice the string
        print("Userlist received: $users");
        _users = users; // Update the list of users
        onUsersUpdated.call(users); // Notify about the updated user list
      } 
      
      else if (message.startsWith("SUCCESSL")) {
        print("Login successful");
        onLoginResult("SUCCESS");        
      } else if (message.startsWith("LOGIN_FAILURE")) {
        print("Login failed");
        onLoginResult("FAILURE");      
      }
      
      else if (message.startsWith("SUCCESSR")) {
        print("Registration successful");
        onRegisterResult("SUCCESS"); // Handle successful registration
      } else if (message.startsWith("REGISTER_FAILURE")) {
        print("Registration failed");
        onRegisterResult("FAILURE"); // Handle registration failure
      }

      else if (message.startsWith("MSG:")) {
        String broadcastMessage = message.substring(4);
        _broadcastMessages.add(broadcastMessage); // Add the broadcast message
        onMessageReceived(broadcastMessage);
      }

      else if (message.startsWith("PRIVATE:")) {
        var parts = message.substring(8).split(":");
        String sender = parts[0];
        String privateMessage = parts[1];
        onPrivateMessageReceived(sender, privateMessage); //Notify the UI about the private message
      }
      
      else {
        onMessageReceived(message);
      }
    }, onError: (error) {
    print("WebSocket error: $error");
  }, onDone: () {
    print("WebSocket closed");
  });
  }

  void sendMessage(String message) {
    _channel.sink.add(message);
  }

  void login(String username, String password) {
    _username = username;
    print("Attempting login for user: $username"); // Debugging line
    sendMessage("LOGIN:$username:$password");
  }

  void register(String username, String password) {
    _username = username;
    sendMessage("REGISTER:$username:$password");
  }

  void sendBroadcastMessage(String message) {
    sendMessage("MSG:$message");
  }
  void sendPrivateMessage(String recipient, String message) {
    sendMessage("PRIVATE:$_username:$recipient:$message");
  }
  void disconnect() {
    _channel.sink.close();
  }
}
