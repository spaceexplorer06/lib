import 'package:eventshive/RegistrationPage.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int standardTickets = 0;
  int vipTickets = 0;

  final eventName = "Splendid Baboon";
  final standardPrice = 0.00;
  final vipPrice = 500.00;

  void updateTicketQuantity(int type, bool increase) {
    setState(() {
      if (type == 0) {
        if (increase) {
          standardTickets++;
        } else if (standardTickets > 0) {
          standardTickets--;
        }
      } else if (type == 1) {
        if (increase) {
          vipTickets++;
        } else if (vipTickets > 0) {
          vipTickets--;
        }
      }
    });
  }

  // Navigate to the Registration Page with the selected tickets
  void navigateToRegistrationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationPage(
          standardTickets: standardTickets,
          vipTickets: vipTickets,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tickets Booking",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Select your tickets below:",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Ticket Types (Standard and VIP)
            ticketItem("Standard", standardPrice, 0),
            ticketItem("VIP", vipPrice, 1),

            SizedBox(height: 20),

            // Close and Register Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the screen
                  },
                  child: Text('Close'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: navigateToRegistrationPage,
                  child: Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget ticketItem(String title, double price, int type) {
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
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('₹ ${price.toStringAsFixed(2)}'),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () => updateTicketQuantity(type, false),
                  icon: Icon(Icons.remove),
                ),
                Text(type == 0 ? standardTickets.toString() : vipTickets.toString()),
                IconButton(
                  onPressed: () => updateTicketQuantity(type, true),
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
