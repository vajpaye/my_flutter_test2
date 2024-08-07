import 'package:flutter/material.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'john.doe@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.teal),
                    title: Text('Phone'),
                    subtitle: Text('+1234567890'),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.teal),
                    title: Text('Location'),
                    subtitle: Text('123 Main Street, City, Country'),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Profile Item 1'),
            ),
            ListTile(
              title: Text('Profile Item 2'),
            ),
            ListTile(
              title: Text('Profile Item 3'),
            ),
          ],
        ),
      ),
    );
  }
}
