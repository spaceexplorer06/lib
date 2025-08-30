import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  final int standardTickets;
  final int vipTickets;

  RegistrationPage({required this.standardTickets, required this.vipTickets});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, TextEditingController>> standardControllers = [];
  final List<Map<String, TextEditingController>> vipControllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for the number of standard tickets
    for (int i = 0; i < widget.standardTickets; i++) {
      standardControllers.add({
        'name': TextEditingController(),
        'phone': TextEditingController(),
        'email': TextEditingController(),
        'gender': TextEditingController(text: 'Male'),  // default value
      });
    }

    // Initialize controllers for the number of VIP tickets
    for (int i = 0; i < widget.vipTickets; i++) {
      vipControllers.add({
        'name': TextEditingController(),
        'phone': TextEditingController(),
        'email': TextEditingController(),
        'gender': TextEditingController(text: 'Male'),  // default value
      });
    }
  }

  // Handle the form submission
  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Registration Successful"),
          content: Text("You have successfully registered for the event!"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Attendee Information")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter Attendee Details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),

                // Standard Ticket Fields
                ...List.generate(widget.standardTickets, (index) {
                  return attendeeForm("Standard Ticket #${index + 1}", index, true);
                }),

                // VIP Ticket Fields
                ...List.generate(widget.vipTickets, (index) {
                  return attendeeForm("VIP Ticket #${index + 1}", index, false);
                }),

                SizedBox(height: 20),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: handleSubmit,
                    child: Text("Register"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Generate individual attendee form
  Widget attendeeForm(String title, int index, bool isStandard) {
    final controllers = isStandard ? standardControllers : vipControllers;
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextFormField(
              controller: controllers[index]['name'],
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) => value!.isEmpty ? 'Name is required' : null,
            ),
            TextFormField(
              controller: controllers[index]['phone'],
              decoration: InputDecoration(labelText: 'Phone'),
              validator: (value) => value!.isEmpty ? 'Phone is required' : null,
            ),
            TextFormField(
              controller: controllers[index]['email'],
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) => value!.isEmpty ? 'Email is required' : null,
            ),
            DropdownButtonFormField<String>(
              value: controllers[index]['gender']?.text ?? 'Male', // default value
              items: ['Male', 'Female', 'Other']
                  .map((gender) => DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  controllers[index]['gender']?.text = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Gender'),
              validator: (value) => value == null ? 'Gender is required' : null,
            ),
          ],
        ),
      ),
    );
  }
}
