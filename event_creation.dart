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

  // Dynamic tickets
  final List<Map<String, TextEditingController>> _ticketControllers = [];

  bool _isPublished = false;
  bool _isLoading = false;

  // ⚡ Replace with your LAN IP (for emulator use 10.0.2.2)
  final String backendBaseUrl = "http://10.53.1.81:3000";

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

  // Date picker
  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = picked.toIso8601String().split("T").first;
    }
  }

  // Create event API call
  Future<void> createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

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
          'price': double.tryParse(ticket['ticketPrice']!.text) ?? 0,
          'quantity': int.tryParse(ticket['ticketQuantity']!.text) ?? 0,
        };
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/create-event'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(eventData),
      );
if (response.statusCode == 201) {
  Navigator.pop(context, true); // ✅ Go back & refresh homepage
} else {
  _showDialog("Error", "Failed to create event. Code: ${response.statusCode}");
}

      if (response.statusCode == 201) {
        Navigator.pop(context, true); // ✅ Go back & refresh homepage
      } else {
        _showDialog("Error", "Failed to create event. Code: ${response.statusCode}");
      }
    } catch (e) {
      _showDialog("Error", "Could not connect to backend. Ensure server is running.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
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
                Text('Event Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),

                TextFormField(
                  controller: _eventNameController,
                  decoration: InputDecoration(labelText: 'Event Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        decoration: InputDecoration(
                          labelText: 'Start Date',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _pickDate(_startDateController),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        decoration: InputDecoration(
                          labelText: 'End Date',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _pickDate(_endDateController),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _registrationStartController,
                        decoration: InputDecoration(
                          labelText: 'Registration Start',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _pickDate(_registrationStartController),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _registrationEndController,
                        decoration: InputDecoration(
                          labelText: 'Registration End',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _pickDate(_registrationEndController),
                          ),
                        ),
                        readOnly: true,
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _addTicketType,
                  icon: Icon(Icons.add),
                  label: Text('Add Ticket Type'),
                ),
                SizedBox(height: 10),

                Column(
                  children: List.generate(_ticketControllers.length, (index) {
                    final ticket = _ticketControllers[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: ticket['ticketType'],
                              decoration: InputDecoration(labelText: 'Ticket Type ${index + 1}'),
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            TextFormField(
                              controller: ticket['ticketPrice'],
                              decoration: InputDecoration(labelText: 'Price'),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            TextFormField(
                              controller: ticket['ticketQuantity'],
                              decoration: InputDecoration(labelText: 'Quantity'),
                              keyboardType: TextInputType.number,
                              validator: (value) => value!.isEmpty ? 'Required' : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _ticketControllers.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Checkbox(
                      value: _isPublished,
                      onChanged: (value) {
                        setState(() => _isPublished = value ?? false);
                      },
                    ),
                    Text("Publish Event"),
                  ],
                ),

                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : createEvent,
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text('Create Event'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
