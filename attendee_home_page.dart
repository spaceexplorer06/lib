import 'dart:convert';
import 'package:eventshive/events_page.dart';
import 'package:eventshive/ticket_booking.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'event_detail_page.dart';
import 'attendee_profile.dart';

class AttendeeHomePage extends StatefulWidget {
  @override
  _AttendeeHomePageState createState() => _AttendeeHomePageState();
}

class _AttendeeHomePageState extends State<AttendeeHomePage> {
  List<dynamic> events = [];
  List<dynamic> filteredEvents = [];
  bool isLoading = true;
  final String backendBaseUrl = "http://10.53.1.81:3000";

  String? _selectedFilterType;

  final List<String> eventTypes = [
    "Conference","Trade Show","Seminar","Workshop","Corporate Meeting","Product Launch",
    "Networking Event","Business Summit","Expo","Convention","Festival","Concert",
    "Performance (Theater, Dance, etc.)","Art Exhibition","Cultural Event","Community Event",
    "Fundraiser","Charity Gala","Auction","Wedding","Birthday Party","Anniversary Celebration",
    "Graduation Ceremony","Baby Shower","Bridal Shower","Family Reunion","Holiday Party",
    "Dinner Party","Banquet","Sporting Event","Marathon","Tournament (e.g., golf, tennis)",
    "Team Building Event","Corporate Retreat","Office Party","Launch Party","Pop-Up Event",
    "Webinar","Virtual Conference","Hybrid Event","Religious Ceremony (e.g., baptism, bar mitzvah)",
    "Funeral Service","Memorial Service","Political Rally","Campaign Event","Press Conference",
    "Customer Appreciation Event","Open House","Training Session","Hackathon"
  ];

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse('$backendBaseUrl/events'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          events = decoded;
          filteredEvents = decoded;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to load events')));
      }
    } catch (e) {
      print('❌ Error fetching events: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to connect to server')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterEvents(String? type) {
    setState(() {
      _selectedFilterType = type;
      if (type == null || type.isEmpty) {
        filteredEvents = events;
      } else {
        filteredEvents = events.where((event) => event['type'] == type).toList();
      }
    });
  }

  Future<void> bookTicket(String eventId, String type, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/events/$eventId/book-ticket'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'type': type, 'quantity': quantity}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('✅ Ticket booked successfully!')));
        fetchEvents();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to book ticket')));
      }
    } catch (e) {
      print('❌ Error booking ticket: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to connect to server')));
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AttendeeProfilePage()),
    );
  }

  void _goToOrganizer() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EventHive - Attendee'),
        actions: [
          IconButton(
            icon: Icon(Icons.switch_account),
            tooltip: 'Go to Organizer',
            onPressed: _goToOrganizer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Simple Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedFilterType,
              hint: Text("Select Event Type"),
              items: eventTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                filterEvents(value);
              },
            ),
          ),

          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredEvents.isEmpty
                    ? Center(child: Text('No events available'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
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
                                  if (event['tickets'] != null &&
                                      event['tickets'].isNotEmpty)
                                    Wrap(
                                      spacing: 8,
                                      children: List.generate(
                                        event['tickets'].length,
                                        (ticketIndex) {
                                          final ticket = event['tickets'][ticketIndex];
                                          return ElevatedButton(
                                            onPressed: ticket['quantity'] > 0
                                                ? () async {
                                                    final result = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => RegisterPage(
                                                          eventId: event['_id'],
                                                          ticketType: ticket['type'],
                                                          ticketPrice:
                                                              ticket['price'].toDouble(),
                                                          availableQuantity:
                                                              ticket['quantity'],
                                                          eventName: '',
                                                        ),
                                                      ),
                                                    );
                                                    if (result != null &&
                                                        result is int &&
                                                        result > 0) {
                                                      await bookTicket(
                                                          event['_id'],
                                                          ticket['type'],
                                                          result);
                                                    }
                                                  }
                                                : null,
                                            child: Text(
                                                '${ticket['type']} - ₹${ticket['price']} (${ticket['quantity']} left)'),
                                          );
                                        },
                                      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openProfile,
        child: Icon(Icons.person),
        tooltip: 'Profile',
      ),
    );
  }
}
