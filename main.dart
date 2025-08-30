import 'package:eventshive/attendee_details.dart';
import 'package:eventshive/event_creation.dart';
import 'package:eventshive/event_detail_page.dart';
import 'package:eventshive/ticket_booking.dart';
import 'package:flutter/material.dart';
import 'events_page.dart'; // Import your Events page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventHive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => RegisterPage(), // The Event List Page
        // You can add more routes for event details, registration, etc. later
      },
    );
  }
}
