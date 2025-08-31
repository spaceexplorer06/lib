import 'package:flutter/material.dart';

class AttendeeProfilePage extends StatelessWidget {
  // Replace these with actual user data from backend or shared preferences
  final String name = "John Doe";
  final String email = "johndoe@example.com";
  final String profileImageUrl =
      "https://www.w3schools.com/w3images/avatar2.png"; // placeholder

  final int totalTicketsBooked = 5; // example statistic

  void _logout(BuildContext context) {
    // Clear session, shared preferences, or token here
    // Then navigate to login page
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(profileImageUrl),
              onBackgroundImageError: (_, __) =>
                  AssetImage('assets/images/placeholder.jpg') as ImageProvider,
            ),
            SizedBox(height: 16),

            // Name
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Email
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),

            Divider(),

            // Stats
            ListTile(
              leading: Icon(Icons.confirmation_num),
              title: Text('Total Tickets Booked'),
              trailing: Text('$totalTicketsBooked'),
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Events Participated'),
              trailing: Text('3'), // example
            ),

            Divider(),

            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to edit profile page (if implemented)
              },
              icon: Icon(Icons.edit),
              label: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
