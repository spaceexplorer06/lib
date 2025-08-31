import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart'; // make sure this is the correct import

class AttendeeProfilePage extends StatefulWidget {
  const AttendeeProfilePage({Key? key}) : super(key: key);

  @override
  _AttendeeProfilePageState createState() => _AttendeeProfilePageState();
}

class _AttendeeProfilePageState extends State<AttendeeProfilePage> {
  String? name;
  String? email;
  String profileImageUrl =
      "https://www.w3schools.com/w3images/avatar2.png"; // placeholder
  int totalTicketsBooked = 5; // example statistic

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('user_name') ?? 'Attendee Name';
      email = prefs.getString('user_email') ?? 'email@example.com';
      // If you also store profile URL during registration/login
      if (prefs.getString('user_profile_url') != null) {
        profileImageUrl = prefs.getString('user_profile_url')!;
      }
    });
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all stored session data

    // Navigate to login page and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(profileImageUrl),
              onBackgroundImageError: (_, __) =>
                  const AssetImage('assets/images/placeholder.jpg')
                      as ImageProvider,
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              name ?? 'Attendee Name',
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Email
            Text(
              email ?? 'email@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            const Divider(),

            // Stats
            ListTile(
              leading: const Icon(Icons.confirmation_num),
              title: const Text('Total Tickets Booked'),
              trailing: Text('$totalTicketsBooked'),
            ),
            const ListTile(
              leading: Icon(Icons.event),
              title: Text('Events Participated'),
              trailing: Text('3'), // example
            ),

            const Divider(),

            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to edit profile page (if implemented)
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
