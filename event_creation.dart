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

  // For dynamic tickets
  final List<Map<String, TextEditingController>> _ticketControllers = [];

  bool _isPublished = false;
  bool _isUploadingPhotos = false;

  // Add new ticket type
  void _addTicketType() {
    setState(() {
      _ticketControllers.add({
        'ticketType': TextEditingController(),
        'ticketPrice': TextEditingController(),
        'ticketQuantity': TextEditingController(),
      });
    });
  }

  // Function to show the date and time picker
  Future<void> _selectDateTime(BuildContext context, TextEditingController controller) async {
    DateTime selectedDate = DateTime.now();

    // Show Date Picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      selectedDate = pickedDate;

      // Show Time Picker
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate),
      );

      if (pickedTime != null) {
        // Combine the selected date and time
        final DateTime fullDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Format the date-time
        controller.text = fullDateTime.toString(); // You can customize the format
      }
    }
  }

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
        'isPublished': _isPublished,
        'tickets': _ticketControllers.map((ticket) {
          return {
            'type': ticket['ticketType']!.text,
            'price': double.parse(ticket['ticketPrice']!.text),
            'quantity': int.parse(ticket['ticketQuantity']!.text),
          };
        }).toList(),
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
                        onTap: () => _selectDateTime(context, _startDateController),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        decoration: InputDecoration(labelText: 'End Date'),
                        validator: (value) => value!.isEmpty ? 'End date is required' : null,
                        onTap: () => _selectDateTime(context, _endDateController),
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
                        onTap: () => _selectDateTime(context, _registrationStartController),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _registrationEndController,
                        decoration: InputDecoration(labelText: 'Registration End Date'),
                        validator: (value) => value!.isEmpty ? 'Registration end date is required' : null,
                        onTap: () => _selectDateTime(context, _registrationEndController),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Add new ticket type section
                ElevatedButton(
                  onPressed: _addTicketType,
                  child: Text('Add New Ticket Type'),
                ),
                SizedBox(height: 10),
                // Ticket types list
                Column(
                  children: List.generate(_ticketControllers.length, (index) {
                    final ticket = _ticketControllers[index];
                    return Column(
                      children: [
                        TextFormField(
                          controller: ticket['ticketType'],
                          decoration: InputDecoration(labelText: 'Ticket Type ${index + 1}'),
                          validator: (value) => value!.isEmpty ? 'Ticket type is required' : null,
                        ),
                        TextFormField(
                          controller: ticket['ticketPrice'],
                          decoration: InputDecoration(labelText: 'Ticket Price ${index + 1}'),
                          keyboardType: TextInputType.number,
                          validator: (value) => value!.isEmpty ? 'Ticket price is required' : null,
                        ),
                        TextFormField(
                          controller: ticket['ticketQuantity'],
                          decoration: InputDecoration(labelText: 'Ticket Quantity ${index + 1}'),
                          keyboardType: TextInputType.number,
                          validator: (value) => value!.isEmpty ? 'Ticket quantity is required' : null,
                        ),
                      ],
                    );
                  }),
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
