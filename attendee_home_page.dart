import 'dart:convert';
import 'package:eventshive/ticket_booking.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'attendee_details.dart';
import 'event_detail_page.dart';

class AttendeeHomePage extends StatefulWidget {
  @override
  _AttendeeHomePageState createState() => _AttendeeHomePageState();
}

class _AttendeeHomePageState extends State<AttendeeHomePage> {
  List<dynamic> events = [];
  bool isLoading = true;

  final String backendBaseUrl = "http://10.53.1.81:3000"; // ⚡ LAN IP

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  // Fetch all events
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

  // Book ticket for an event (API call)
  Future<void> bookTicket(String eventId, String type, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/events/$eventId/book-ticket'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'type': type, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Ticket booked successfully!')),
        );
        fetchEvents(); // Refresh event list to show updated ticket quantity
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book ticket')),
        );
      }
    } catch (e) {
      print('❌ Error booking ticket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to server')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EventHive - Attendee'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'organizer') {
                Navigator.pushReplacementNamed(context, '/'); // Go back to organizer
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'organizer',
                child: Text('Switch to Organizer Home'),
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
            if (isLoading)
              Expanded(child: Center(child: CircularProgressIndicator())),

            if (!isLoading)
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Info
                            ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  event['imageUrl'] ?? '',
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/images/placeholder.jpg',
                                    width: 60,
                                    height: 60,
                                  ),
                                ),
                              ),
                              title: Text(
                                event['name'] ?? 'No Title',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(event['description'] ?? ''),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EventDetailPage(eventId: event['_id']),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 6),

                            // Tickets info + Booking
                            if (event['tickets'] != null &&
                                event['tickets'].isNotEmpty)
                              Wrap(
                                spacing: 8,
                                children: List.generate(
                                    event['tickets'].length, (ticketIndex) {
                                  final ticket = event['tickets'][ticketIndex];

                                  return ElevatedButton(
                                    onPressed: ticket['quantity'] > 0
                                        ? () async {
                                            // Navigate to RegisterPage
                                            final result =
                                                await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => RegisterPage(
                                                  eventId: event['_id'],
                                                  ticketType: ticket['type'],
                                                  ticketPrice:
                                                      ticket['price'].toDouble(),
                                                  availableQuantity:
                                                      ticket['quantity'], eventName: '',
                                                ),
                                              ),
                                            );

                                            // If user booked tickets, call API
                                            if (result != null &&
                                                result is int &&
                                                result > 0) {
                                              await bookTicket(event['_id'],
                                                  ticket['type'], result);
                                            }
                                          }
                                        : null,
                                    child: Text(
                                        '${ticket['type']} - ₹${ticket['price']} (${ticket['quantity']} left)'),
                                  );
                                }),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('No tickets available'),
                              ),
                          ],
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
