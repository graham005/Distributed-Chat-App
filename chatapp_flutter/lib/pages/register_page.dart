// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class RegisterPage extends StatefulWidget {
  final ChatService _chatService;

  const RegisterPage(this._chatService, {super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        automaticallyImplyLeading: false,),
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
                      SnackBar(content: Text('Please enter a username and password'))
                    );
                  } else {
                    setState(() {
                      _isLoading = true;
                    });
          
                    // Connect to the server and attenpt registration
                    try{
                      await widget._chatService.connectToServer();
          
                      // Listen for registration result
                      widget._chatService.onRegisterResult = ( status) {
                        if (status == "SUCCESS") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Registration successful.'))
                          );
                          Navigator.pushNamed(context, '/navbar');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Registration failed. Please try again.'))
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      };
                      // Attempt registration
                      widget._chatService.register(_usernameController.text, _passwordController.text);
                    } catch (e) {
                      print ('Error connecting to server: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to connect to server. Please try again later.'))
                      );
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                },
                child: Text('Register')
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/');
                    }, 
                    child: Text('Login')
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