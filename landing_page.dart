import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/landing.jpg', // Path to your background image
              fit: BoxFit.cover, // Makes the image cover the whole screen
            ),
          ),
          // Overlaying content (buttons, text)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Title
                Image.asset(
                  'assets/images/logo1.png', // Your app logo
                  height: 100,
                  width: 100,
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome to EventHive',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Create, manage, and track your events easily!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                // Buttons
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the event creation page
                    Navigator.pushNamed(context, '/create-event');
                  },
                  child: Text('Get Started'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Button color
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    // Navigate to login page if needed
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'Already have an account? Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
