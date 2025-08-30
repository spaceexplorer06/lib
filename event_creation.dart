import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for event fields
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

  // Replace with your backend IP
  final String backendBaseUrl = "http://10.53.1.81:3000";

  // Add new ticket
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    if (token == null) {
      _showDialog("Unauthorized", "You must be logged in to create an event.");
      setState(() => _isLoading = false);
      return;
    }

    final eventData = {
      'name': _eventNameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'startDate': _startDateController.text.trim(),
      'endDate': _endDateController.text.trim(),
      'registrationStart': _registrationStartController.text.trim(),
      'registrationEnd': _registrationEndController.text.trim(),
      'isPublished': _isPublished,
      'tickets': _ticketControllers.map((ticket) {
        return {
          'type': ticket['ticketType']!.text.trim(),
          'price': double.tryParse(ticket['ticketPrice']!.text.trim()) ?? 0,
          'quantity': int.tryParse(ticket['ticketQuantity']!.text.trim()) ?? 0,
        };
      }).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/create-event'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ⚡ JWT header
        },
        body: jsonEncode(eventData),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? "Event created successfully!")),
        );
        Navigator.pop(context, true); // Go back and refresh homepage
      } else if (response.statusCode == 401) {
        _showDialog("Unauthorized", "Session expired or invalid token. Please login again.");
      } else {
        _showDialog("Error", data['error'] ?? "Failed to create event. Code: ${response.statusCode}");
      }
    } catch (e) {
      _showDialog("Error", "Could not connect to backend. Ensure server is running.");
      print(e);
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text("OK")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Event Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                _buildTextField('Event Name', _eventNameController),
                const SizedBox(height: 10),
                _buildTextField('Description', _descriptionController),
                const SizedBox(height: 10),
                _buildTextField('Location', _locationController),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _buildDateField('Start Date', _startDateController),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDateField('End Date', _endDateController),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField('Registration Start', _registrationStartController),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDateField('Registration End', _registrationEndController),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _addTicketType,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Ticket Type'),
                ),
                const SizedBox(height: 10),

                Column(
                  children: List.generate(_ticketControllers.length, (index) {
                    final ticket = _ticketControllers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            _buildTextField('Ticket Type ${index + 1}', ticket['ticketType']!),
                            _buildTextField('Price', ticket['ticketPrice']!, keyboardType: TextInputType.number),
                            _buildTextField('Quantity', ticket['ticketQuantity']!, keyboardType: TextInputType.number),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => setState(() => _ticketControllers.removeAt(index)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),

                Row(
                  children: [
                    Checkbox(value: _isPublished, onChanged: (val) => setState(() => _isPublished = val ?? false)),
                    const Text("Publish Event"),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : createEvent,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Event'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => _pickDate(controller)),
      ),
    );
  }
}
