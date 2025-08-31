import 'dart:convert';
import 'package:eventshive/attendee_details.dart';
import 'package:eventshive/attendee_home_page.dart';
import 'package:eventshive/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
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
  List<dynamic> filteredEvents = [];
  bool isLoading = true;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

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
          filteredEvents = events; // initially all events
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ You are not logged in')));
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

      if (response.statusCode == 200) {
        setState(() {
          events.removeWhere((event) => event['_id'] == eventId);
          filteredEvents.removeWhere((event) => event['_id'] == eventId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Event deleted successfully')),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '❌ Failed to delete event: ${data['message'] ?? 'Unknown error'}')),
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

  void filterEvents(String query) {
    final results = events.where((event) {
      final name = event['name']?.toLowerCase() ?? '';
      final location = event['location']?.toLowerCase() ?? '';
      final search = query.toLowerCase();
      return name.contains(search) || location.contains(search);
    }).toList();

    setState(() {
      filteredEvents = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? const Text('EventHive - Organizer')
            : TextField(
                controller: searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search events...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white60),
                ),
                style: const TextStyle(color: Color.fromARGB(255, 57, 1, 103), fontSize: 18),
                onChanged: filterEvents,
              ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  filteredEvents = events;
                }
                isSearching = !isSearching;
              });
            },
          ),
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
              const PopupMenuItem(
                value: 'attendee',
                child: Text('Switch to Attendee Home'),
              ),
            ],
            icon: const Icon(Icons.menu),
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
                  child: const Text('Add New Event'),
                ),
              ],
            ),

            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator())),

            if (!isLoading)
              Expanded(
                child: filteredEvents.isEmpty
                    ? const Center(child: Text('No events found'))
                    : ListView.builder(
                        itemCount: filteredEvents.length,
                        itemBuilder: (context, index) {
                          final event = filteredEvents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
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
                                          builder: (_) => EventDetailPage(
                                              eventId: event['_id']),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event['name'] ?? "No Title",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                event['description'] ??
                                                    "No Description",
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on,
                                                      size: 16,
                                                      color: Colors.red),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      event['location'] ??
                                                          "Unknown",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Icon(Icons.calendar_today,
                                                      size: 16,
                                                      color: Colors.blue),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      event['startDate'] ??
                                                          "N/A",
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text(
                                              'Are you sure you want to delete this event?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteEvent(event['_id']);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Delete',
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
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        overlayOpacity: 0.4,
        spacing: 10,
        spaceBetweenChildren: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => OrganizerProfile()),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.list),
            label: 'Attendee List',
            backgroundColor: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AttendeesPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
