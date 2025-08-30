import 'dart:convert';
import 'package:eventshive/event_creation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> events = [];
  bool isLoading = true; // Loading state

  // Fetch events from the backend API
  Future<void> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/events'));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          events = jsonDecode(response.body); // Parse JSON response
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching events: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to fetch events')));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvents(); // Fetch events when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EventHive - Organizer')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Add New Event Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the CreateEventPage when the button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateEventPage()),
                    );
                  },
                  child: Text('Add New Event'),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Search functionality
                  },
                ),
              ],
            ),
            // Loading indicator
            if (isLoading)
              Center(child: CircularProgressIndicator()),
            // Event List
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Image.network(event['imageUrl'] ?? 'https://via.placeholder.com/150'),
                      title: Text(event['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(event['type']),
                          Row(
                            children: [
                              Text('Date: ${event['date']}'),
                              SizedBox(width: 10),
                              Text('Location: ${event['location']}'),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(event['status'] == 'Available' ? Icons.lock_open : Icons.lock),
                        onPressed: () {
                          // Toggle event status between Available/Unavailable
                          setState(() {
                            event['status'] = event['status'] == 'Available' ? 'Unavailable' : 'Available';
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
