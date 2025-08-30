import 'package:flutter/material.dart';

class AttendeesPage extends StatefulWidget {
  @override
  _AttendeesPageState createState() => _AttendeesPageState();
}

class _AttendeesPageState extends State<AttendeesPage> {
  List<Map<String, String>> attendees = [
    {
      'name': 'Priya Sharma',
      'totalGuests': '2',
      'email': 'priya@email.com',
      'phone': '1234564789',
      'gender': 'Female',
    },
    {
      'name': 'Marc',
      'totalGuests': '1',
      'email': 'Marc@odoo.com',
      'phone': '2536548952',
      'gender': 'Male',
    },
    {
      'name': 'Arjun Patel',
      'totalGuests': '1',
      'email': 'arjun@example.com',
      'phone': '25463598755',
      'gender': 'Male',
    },
  ];

  String searchQuery = "";
  String selectedGender = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EventHive - Attendees"),
        actions: [
          // Search bar
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              showSearch(context: context, delegate: AttendeeSearchDelegate());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter Row (Gender Filter)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: selectedGender,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue!;
                    });
                  },
                  items: <String>['All', 'Male', 'Female']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Text("Gender: $selectedGender"),
              ],
            ),
            SizedBox(height: 20),

            // Attendees List
            Expanded(
              child: ListView.builder(
                itemCount: attendees.length,
                itemBuilder: (context, index) {
                  final attendee = attendees[index];

                  // Filter attendees based on gender
                  if (selectedGender != 'All' && attendee['gender'] != selectedGender) {
                    return Container();
                  }

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                attendee['name']!,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text("Total Guests: ${attendee['totalGuests']}"),
                              Text("Email: ${attendee['email']}"),
                              Text("Phone: ${attendee['phone']}"),
                              Text("Gender: ${attendee['gender']}"),
                            ],
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

class AttendeeSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => "Search Attendees...";

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildAttendeeList(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildAttendeeList(query);
  }

  Widget _buildAttendeeList(String query) {
    final filteredAttendees = [
      {
        'name': 'Priya Sharma',
        'totalGuests': '2',
        'email': 'priya@email.com',
        'phone': '1234564789',
        'gender': 'Female',
      },
      {
        'name': 'Marc',
        'totalGuests': '1',
        'email': 'Marc@odoo.com',
        'phone': '2536548952',
        'gender': 'Male',
      },
      {
        'name': 'Arjun Patel',
        'totalGuests': '1',
        'email': 'arjun@example.com',
        'phone': '25463598755',
        'gender': 'Male',
      },
    ].where((attendee) {
      return attendee['name']!.toLowerCase().contains(query.toLowerCase()) ||
          attendee['email']!.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: filteredAttendees.length,
      itemBuilder: (context, index) {
        final attendee = filteredAttendees[index];

        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendee['name']!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Total Guests: ${attendee['totalGuests']}"),
                    Text("Email: ${attendee['email']}"),
                    Text("Phone: ${attendee['phone']}"),
                    Text("Gender: ${attendee['gender']}"),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
