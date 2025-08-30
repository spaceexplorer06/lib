import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class RegisterPage extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String ticketType;
  final double ticketPrice;
  final int availableQuantity;

  RegisterPage({
    required this.eventId,
    required this.eventName,
    required this.ticketType,
    required this.ticketPrice,
    required this.availableQuantity,
  });

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int ticketCount = 0;
  bool isLoading = false;
  final String backendBaseUrl = "http://10.53.1.81:3000";

  void updateTicketCount(bool increase) {
    setState(() {
      if (increase && ticketCount < widget.availableQuantity) ticketCount++;
      if (!increase && ticketCount > 0) ticketCount--;
    });
  }

  Future<void> confirmBooking() async {
    if (ticketCount == 0) {
      _showSnackBar('Select at least one ticket');
      return;
    }

    bool paymentSuccess =
        await showDummyPaymentScreen(ticketCount * widget.ticketPrice);
    if (!paymentSuccess) return;

    setState(() => isLoading = true);
    bool backendSuccess = false;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('$backendBaseUrl/events/${widget.eventId}/book-ticket'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'type': widget.ticketType,
            'quantity': ticketCount,
          }),
        );

        print('Booking Status: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          backendSuccess = true;
          final data = jsonDecode(response.body);
          if (data['pdf'] != null) await _saveAndOpenPdf(data['pdf']);
          _showSnackBar('✅ Ticket booked successfully!');
        } else {
          _showSnackBar(
              '⚠️ Could not confirm with server. Ticket saved locally.');
        }
      } else {
        _showSnackBar(
            '⚠️ Not logged in. Ticket will be saved locally.');
      }
    } catch (e) {
      print('Error booking ticket: $e');
      _showSnackBar('⚠️ Could not connect to server. Ticket saved locally.');
    } finally {
      setState(() => isLoading = false);
      if (!backendSuccess) await _generateFancyPdf();
      Navigator.pop(context, ticketCount);
    }
  }

  Future<bool> showDummyPaymentScreen(double amount) async {
    bool success = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: Text("Dummy Payment - ₹$amount"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter dummy card details to simulate payment"),
              SizedBox(height: 10),
              TextField(decoration: InputDecoration(labelText: "Card Number")),
              TextField(decoration: InputDecoration(labelText: "Expiry MM/YY")),
              TextField(decoration: InputDecoration(labelText: "CVV")),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: Colors.red))),
            ElevatedButton(
                onPressed: () {
                  success = true;
                  Navigator.pop(context);
                },
                child: Text("Pay")),
          ],
        ),
      ),
    );

    _showSnackBar(success ? "✅ Payment Successful!" : "❌ Payment Cancelled");
    return success;
  }

  Future<void> _saveAndOpenPdf(String base64Pdf) async {
    try {
      final bytes = base64Decode(base64Pdf);
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file =
          File('${directory.path}/ticket_${widget.eventId}_$timestamp.pdf');
      await file.writeAsBytes(bytes, flush: true);
      await OpenFile.open(file.path);
    } catch (e) {
      print('PDF error: $e');
      _showSnackBar('❌ Failed to open PDF');
    }
  }

  Future<Uint8List> _generateQrImage(String data, int size) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: true,
      color: Colors.black,
      emptyColor: Colors.white,
    );
    final picData = await painter.toImageData(size.toDouble());
    return picData!.buffer.asUint8List();
  }

  Future<void> _generateFancyPdf() async {
    try {
      final pdf = pw.Document();
      final qrBytes = await _generateQrImage(
        'Event:${widget.eventName}|Type:${widget.ticketType}|Qty:$ticketCount',
        200,
      );

      pdf.addPage(
        pw.Page(
          build: (context) => pw.Container(
            padding: pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border:
                  pw.Border.all(color: PdfColor.fromInt(0xFF6200EE), width: 3),
              borderRadius: pw.BorderRadius.circular(12),
              color: PdfColor.fromInt(0xFFEDE7F6),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('🎟️ EVENT TICKET',
                    style:
                        pw.TextStyle(fontSize: 28, color: PdfColor.fromInt(0xFF6200EE))),
                pw.SizedBox(height: 12),
                pw.Divider(color: PdfColor.fromInt(0xFF6200EE), thickness: 2),
                pw.SizedBox(height: 12),
                pw.Text('Event: ${widget.eventName}',
                    style: pw.TextStyle(fontSize: 20)),
                pw.Text('Ticket Type: ${widget.ticketType}',
                    style: pw.TextStyle(fontSize: 18)),
                pw.Text('Quantity: $ticketCount',
                    style: pw.TextStyle(fontSize: 18)),
                pw.Text('Price per Ticket: ₹${widget.ticketPrice}',
                    style: pw.TextStyle(fontSize: 18)),
                pw.Text('Total: ₹${widget.ticketPrice * ticketCount}',
                    style: pw.TextStyle(fontSize: 18)),
                pw.SizedBox(height: 20),
                pw.Image(pw.MemoryImage(qrBytes), width: 120, height: 120),
                pw.SizedBox(height: 10),
                pw.Text('Show this QR code at the entrance',
                    style: pw.TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file =
          File('${directory.path}/ticket_${widget.eventId}_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save(), flush: true);
      await OpenFile.open(file.path);
    } catch (e) {
      print('PDF generation error: $e');
      _showSnackBar('❌ Failed to generate PDF');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tickets Booking",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text("Select your tickets below:", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.ticketType,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              Text('₹ ${widget.ticketPrice.toStringAsFixed(2)}'),
                              Text('Available: ${widget.availableQuantity}'),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                  onPressed: () => updateTicketCount(false),
                                  icon: Icon(Icons.remove)),
                              Text(ticketCount.toString()),
                              IconButton(
                                  onPressed: () => updateTicketCount(true),
                                  icon: Icon(Icons.add)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: isLoading ? null : confirmBooking,
                        child: Text('Confirm Booking'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
