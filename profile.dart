  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class OrganizerProfile extends StatefulWidget {
    @override
    _OrganizerProfileState createState() => _OrganizerProfileState();
  }

  class _OrganizerProfileState extends State<OrganizerProfile> {
    String? name;
    String? email;
    String? profileUrl;

    @override
    void initState() {
      super.initState();
      _loadProfile();
    }

    Future<void> _loadProfile() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        name = prefs.getString('organizer_name') ?? 'Organizer Name';
        email = prefs.getString('organizer_email') ?? 'email@example.com';
        profileUrl = prefs.getString('organizer_profile_url'); // optional
      });
    }

    void _logout() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      // Redirect to login page or home
      Navigator.pushReplacementNamed(context, '/login');
    }

    void _editProfile() {
      // Navigate to a profile edit page (you can implement later)
      Navigator.pushNamed(context, '/edit_profile');
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(height: 30),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: profileUrl != null
                      ? NetworkImage(profileUrl!)
                      : AssetImage('assets/images/profile_placeholder.png')
                          as ImageProvider,
                ),
                SizedBox(height: 20),
                Text(
                  name ?? '',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  email ?? '',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: _editProfile,
                  icon: Icon(Icons.edit),
                  label: Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _logout,
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
