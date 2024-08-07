import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ReviewPage extends StatefulWidget {
  final String location;
  final String placeKey;
  final String placeTitle;

  ReviewPage({required this.location, required this.placeKey, required this.placeTitle});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('favorites');
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0.0;
  bool _isSubmitting = false;

  void _submitReview() async {
    if (_commentController.text.isEmpty || _rating == 0.0) {
      // Show error message if comment or rating is not provided
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please provide both a comment and a rating.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Create a new comment
    final newComment = {
      'comment': _commentController.text,
      'rating': _rating,
      'username': 'anonymous_user', // You can replace this with the actual username
    };

    // Push the new comment to the correct path in Firebase
    await _database.child(widget.location).child(widget.placeKey).child('comments').push().set(newComment);

    setState(() {
      _isSubmitting = false;
      _commentController.clear();
      _rating = 0.0;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review submitted successfully!')),
    );

    // Redirect to the home page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write a Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Place : ${widget.placeTitle}',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Location: ${widget.location}', // Display the location
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              'Write your review about this place',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Comments section...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Rating',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 30,
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submitReview,
                child: _isSubmitting
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
