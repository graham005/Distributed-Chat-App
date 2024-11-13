// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class LoginPage extends StatefulWidget {
  final ChatService _chatService;

  const LoginPage(this._chatService, {super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), automaticallyImplyLeading: false),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController, 
                decoration: InputDecoration(labelText: 'Username')),
              TextField(
                controller: _passwordController, 
                decoration: InputDecoration(labelText: 'Password'), obscureText: true),
              SizedBox(height: 20),
              _isLoading ? CircularProgressIndicator() : ElevatedButton(
                onPressed: () async {
                  if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter both username and password'))
                    );
                  } else {
                    setState(() {
                      _isLoading = true;
                    });
          
                    // Connect to server
                    try{
                      await widget._chatService.connectToServer();

                      // Attempt login
                      widget._chatService.login(
                                    _usernameController.text, 
                                    _passwordController.text);
                      //Listen for login result
                      widget._chatService.onLoginResult = (status) {
                        print("Login result recieved: $status");
                        setState(() {
                            _isLoading = false;
                          });
                        
                        if (status == "SUCCESS"){
                          Navigator.pushNamed(context, '/navbar');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Login failed. Please try again.'))
                          );
                        }
                      };
                    } catch (e) {
                      
                      print('Error connecting to server: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to connect to server. Please try again later.'))
                      );
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: Text('Login')
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Dont't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    }, 
                    child: Text('Register')
                  )
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}
