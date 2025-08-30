import 'dart:convert';
import 'package:eventshive/attendee_home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'event_creation.dart';
import 'event_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> events = [];
  bool isLoading = true;

  final String backendBaseUrl = "http://10.53.1.81:3000";

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  // Fetch events
  Future<void> fetchEvents() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$backendBaseUrl/events'));

      if (response.statusCode == 200) {
        setState(() {
          events = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to load events')),
        );
      }
    } catch (e) {
      print('❌ Error fetching events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to connect to server')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Delete event with proper token handling
  Future<void> deleteEvent(String eventId) async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ You are not logged in')));
        setState(() => isLoading = false);
        return;
      }

      final response = await http.delete(
        Uri.parse('$backendBaseUrl/events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete Status: ${response.statusCode}');
      print('Delete Response: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          events.removeWhere((event) => event['_id'] == eventId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Event deleted successfully')),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to delete event: ${data['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      print('❌ Error deleting event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Could not connect to server')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventHive - Organizer'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'attendee') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AttendeeHomePage()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'attendee',
                child: Text('Switch to Attendee Home'),
              ),
            ],
            icon: Icon(Icons.menu),
          ),
        ],
      ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreateEventPage()),
                    ).then((value) {
                      if (value == true) fetchEvents();
                    });
                  },
                  child: Text('Add New Event'),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),

            // Loading spinner
            if (isLoading)
              Expanded(child: Center(child: CircularProgressIndicator())),

            // Event List
            if (!isLoading)
              Expanded(
                child: events.isEmpty
                    ? Center(child: Text('No events found'))
                    : ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              EventDetailPage(eventId: event['_id']),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            event['imageUrl'] ?? '',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/placeholder.jpg',
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event['name'] ?? "No Title",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                event['description'] ?? "No Description",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on,
                                                      size: 16, color: Colors.red),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      event['location'] ?? "Unknown",
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(Icons.calendar_today,
                                                      size: 16, color: Colors.blue),
                                                  SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      event['startDate'] ?? "N/A",
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          event['isPublished'] == true
                                              ? Icons.check_circle
                                              : Icons.cancel,
                                          color: event['isPublished'] == true
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text('Confirm Delete'),
                                          content: Text(
                                              'Are you sure you want to delete this event?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteEvent(event['_id']);
                                                Navigator.pop(context);
                                              },
                                              child: Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
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
