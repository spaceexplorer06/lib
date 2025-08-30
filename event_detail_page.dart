import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EventDetailPage extends StatefulWidget {
  final String eventId;
  EventDetailPage({required this.eventId});

  @override
  _EventDetailPageState createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  Map<String, dynamic>? event;
  bool isLoading = true;

  final String backendBaseUrl = "http://10.53.1.81:3000"; // same as HomePage

  // Fetch single event by ID
  Future<void> fetchEvent() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$backendBaseUrl/events/${widget.eventId}'));

      if (response.statusCode == 200) {
        setState(() {
          event = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load event')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not connect to server')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchEvent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event?['name'] ?? 'Event Details')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : event == null
              ? Center(child: Text('Event not found'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event image
                      Image.network(
                        event!['imageUrl'] ?? '',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset('assets/images/placeholder.jpg', height: 200),
                      ),
                      SizedBox(height: 16),

                      // Event Name
                      Text(
                        event!['name'] ?? 'No Title',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),

                      // Description
                      Text(event!['description'] ?? 'No Description'),
                      SizedBox(height: 8),

                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 4),
                          Text(event!['location'] ?? 'Unknown'),
                        ],
                      ),
                      SizedBox(height: 4),

                      // Start & End Dates
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blue, size: 18),
                          SizedBox(width: 4),
                          Text("Start: ${event!['startDate'] ?? 'N/A'}"),
                          SizedBox(width: 16),
                          Text("End: ${event!['endDate'] ?? 'N/A'}"),
                        ],
                      ),
                      SizedBox(height: 8),

                      // Registration Dates
                      Text(
                        "Registration: ${event!['registrationStart'] ?? 'N/A'} - ${event!['registrationEnd'] ?? 'N/A'}",
                      ),
                      SizedBox(height: 12),

                      // Publish status
                      Row(
                        children: [
                          Text(
                            "Published: ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            event!['isPublished'] == true ? Icons.check_circle : Icons.cancel,
                            color: event!['isPublished'] == true ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Tickets
                      Text(
                        "Tickets",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      if (event!['tickets'] != null && event!['tickets'].isNotEmpty)
                        Column(
                          children: List.generate(event!['tickets'].length, (index) {
                            final t = event!['tickets'][index];
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 4),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(t['type'] ?? 'Ticket'),
                                    Text("\$${t['price'] ?? 0}"),
                                    Text("Qty: ${t['quantity'] ?? 0}"),
                                  ],
                                ),
                              ),
                            );
                          }),
                        )
                      else
                        Text("No tickets available"),
                    ],
                  ),
                ),
    );
  }
}
