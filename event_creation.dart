import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _registrationStartController = TextEditingController();
  final TextEditingController _registrationEndController = TextEditingController();

  // For tickets
  final TextEditingController _standardPriceController = TextEditingController();
  final TextEditingController _vipPriceController = TextEditingController();
  final TextEditingController _standardTicketsController = TextEditingController();
  final TextEditingController _vipTicketsController = TextEditingController();

  // For questions (Name, Email, Gender)
  final TextEditingController _question1Controller = TextEditingController();
  final TextEditingController _question2Controller = TextEditingController();

  bool _isPublished = false;
  bool _isUploadingPhotos = false;

  // Function to send event data to backend
  Future<void> createEvent() async {
    if (_formKey.currentState!.validate()) {
      // Collect data from the form
      final eventData = {
        'name': _eventNameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'registrationStart': _registrationStartController.text,
        'registrationEnd': _registrationEndController.text,
        'standardPrice': double.parse(_standardPriceController.text),
        'vipPrice': double.parse(_vipPriceController.text),
        'standardTickets': int.parse(_standardTicketsController.text),
        'vipTickets': int.parse(_vipTicketsController.text),
        'isPublished': _isPublished,
        'questions': {
          'question1': _question1Controller.text,
          'question2': _question2Controller.text,
        },
      };

      try {
        // Replace with your backend URL
        final response = await http.post(
          Uri.parse('http://your-backend-url.com/create-event'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(eventData),
        );

        if (response.statusCode == 201) {
          // Event created successfully
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Event Created"),
              content: Text("The event has been created successfully!"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          );
        } else {
          // Error response from the backend
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Error"),
              content: Text("Failed to create the event. Please try again."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Network or server error
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Error"),
            content: Text("An error occurred. Please try again later."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Event Details', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                TextFormField(
                  controller: _eventNameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                  validator: (value) => value!.isEmpty ? 'Event name is required' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Event Description'),
                  validator: (value) => value!.isEmpty ? 'Event description is required' : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Location is required' : null,
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        decoration: InputDecoration(labelText: 'Start Date'),
                        validator: (value) => value!.isEmpty ? 'Start date is required' : null,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        decoration: InputDecoration(labelText: 'End Date'),
                        validator: (value) => value!.isEmpty ? 'End date is required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Registration Dates
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _registrationStartController,
                        decoration: InputDecoration(labelText: 'Registration Start Date'),
                        validator: (value) => value!.isEmpty ? 'Registration start date is required' : null,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _registrationEndController,
                        decoration: InputDecoration(labelText: 'Registration End Date'),
                        validator: (value) => value!.isEmpty ? 'Registration end date is required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _standardPriceController,
                        decoration: InputDecoration(labelText: 'Standard Ticket Price'),
                        validator: (value) => value!.isEmpty ? 'Price is required' : null,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _vipPriceController,
                        decoration: InputDecoration(labelText: 'VIP Ticket Price'),
                        validator: (value) => value!.isEmpty ? 'Price is required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _standardTicketsController,
                        decoration: InputDecoration(labelText: 'Standard Tickets'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Number of tickets is required' : null,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _vipTicketsController,
                        decoration: InputDecoration(labelText: 'VIP Tickets'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Number of tickets is required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: createEvent,
                  child: Text('Create Event'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
