import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: isLoggedIn 
          ? _buildLoggedInView()
          : _buildLoggedOutView(context),
      ),
    );
  }

  Widget _buildLoggedInView() {
    final user = FirebaseAuth.instance.currentUser!;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          child: Icon(Icons.person, size: 50),
        ),
        SizedBox(height: 20),
        Text(
          user.email ?? 'Anonymous User',
          style: TextStyle(fontSize: 20),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          child: Text('Sign Out'),
        ),
      ],
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Please log in to view your profile',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to login screen
          },
          child: Text('Login'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to registration screen
          },
          child: Text('Create Account'),
        ),
      ],
    );
  }
}
