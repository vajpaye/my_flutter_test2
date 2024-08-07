import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';

class SettingsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Replace with actual profile image
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Account Name',
                    style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            _buildMenuItem(Icons.person, 'Profile', () {
              // Navigate to profile page
            }),
            _buildDivider(),
            _buildMenuItem(Icons.support, 'Support', () {
              // Navigate to support page
            }),
            _buildDivider(),
            _buildMenuItem(Icons.policy, 'Terms', () {
              // Navigate to terms page
            }),
            _buildDivider(),
            Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MyApp()),
                      (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Sign Out',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(color: Colors.grey[700]);
  }
}
