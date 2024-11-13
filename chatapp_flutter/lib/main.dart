import 'navbar.dart';
import 'pages/login_page.dart';
import 'pages/private_chat_page.dart';
import 'pages/register_page.dart';
import 'pages/users_page.dart';
import 'services/chat_service.dart';
import 'package:flutter/material.dart';
import 'pages/broadcast_page.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ChatService _chatService = ChatService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(_chatService),
        '/register': (context) => RegisterPage(_chatService),
        '/broadcast': (context) => BroadcastPage(_chatService),
        '/users': (context) => UsersPage(_chatService),
        '/privateChat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PrivateChatPage(args['chatService'], args['recipientUsername']);
        },
        '/navbar': (context) => HomePage(_chatService),
      }
    );
  }
}
