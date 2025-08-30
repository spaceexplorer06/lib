import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class EventDetailPage extends StatelessWidget {
  // Sample data (replace with actual data)
  final eventData = {
    'title': 'Live Music Festival',
    'description':
        'Experience live music, local food, and beverages. The 12th edition of our Live Musical Festival!',
    'date': 'Aug 14, 1:30 PM - 5:30 PM',
    'location': 'Silver Auditorium, Ahmedabad, Gujarat',
    'organizer': 'Marc Demo',
    'contact': 'Olympus@yourcompany.com',
    'imageUrls': [
      'https://your-image-url.com/image1.jpg',
      'https://your-image-url.com/image2.jpg',
      'https://your-image-url.com/image3.jpg',
    ]
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventData['title'] as String)),
      body: SingleChildScrollView( // Make the entire body scrollable
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image Carousel
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 2.0,
                viewportFraction: 0.9,
              ),
              items: (eventData['imageUrls'] as List<String>).map<Widget>((item) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      item,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Event Description (wrapped in Flexible widget to avoid overflow)
            Flexible(
              child: Text(
                eventData['description'] as String,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                overflow: TextOverflow.ellipsis, // Avoid long text overflow
                maxLines: 4, // Limit text to 4 lines
              ),
            ),
            SizedBox(height: 20),

            // Event Date & Location
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date & Time',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(eventData['date'] as String),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(eventData['location'] as String),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            // Event Organizer
            Text(
              'Organizer: ${eventData['organizer'] as String}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Contact: ${eventData['contact'] as String}',
              style: TextStyle(color: Colors.blue),
            ),
            SizedBox(height: 20),

            // Register Button (wrapped in Align widget to center)
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  // Register functionality here
                },
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Report Spam Button (also centered)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  // Report spam functionality here
                },
                child: Text(
                  'Report Spam',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Social Media & Share (centered icons)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    // Share event functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.facebook),
                  onPressed: () {
                    // Facebook share functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.facebook),
                  onPressed: () {
                    // Twitter share functionality
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
