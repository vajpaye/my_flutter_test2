import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              ),
              SizedBox(height: 20),
              _buildTextField(_nameController, 'Name', Icons.person),
              SizedBox(height: 15),
              _buildTextField(_emailController, 'Email ID', Icons.email),
              SizedBox(height: 15),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone),
              SizedBox(height: 15),
              _buildTextField(_genderController, 'Gender', Icons.person_outline),
              SizedBox(height: 15),
              _buildTextField(_dobController, 'Date of Birth', Icons.calendar_today),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Save profile changes
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Save',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: UnderlineInputBorder(),
        filled: true,
        fillColor: Colors.transparent,
      ),
    );
  }
}
