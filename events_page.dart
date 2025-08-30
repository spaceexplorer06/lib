import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'event_creation.dart';
import 'event_detail_page.dart'; // ✅ Create this page as discussed

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> events = [];
  bool isLoading = true;

  final String backendBaseUrl = "http://10.53.1.81:3000"; // ⚡ Use your LAN IP

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
          SnackBar(content: Text('Failed to load events')),
        );
      }
    } catch (e) {
      print('❌ Error fetching events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvents();
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
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];

                    return GestureDetector(
                      onTap: () {
                        // ✅ Navigate to EventDetailPage on tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventDetailPage(eventId: event['_id']),
                          ),
                        );
                      },
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Event Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  event['imageUrl'] ?? '',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
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

                              // Event Info
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
                                        Icon(Icons.location_on, size: 16, color: Colors.red),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            event['location'] ?? "Unknown",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.calendar_today, size: 16, color: Colors.blue),
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

                              // Status Icon
                              Icon(
                                event['isPublished'] == true ? Icons.check_circle : Icons.cancel,
                                color: event['isPublished'] == true ? Colors.green : Colors.red,
                              ),
                            ],
                          ),
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
