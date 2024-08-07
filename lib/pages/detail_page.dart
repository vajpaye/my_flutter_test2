import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DetailPage extends StatefulWidget {
  final String location;
  final int itemId;

  DetailPage({required this.location, required this.itemId});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('favorites');
  Map<String, dynamic>? itemData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchItemData();
  }

  void _fetchItemData() async {
    _database.child(widget.location).child(widget.itemId.toString()).once().then((DatabaseEvent event) {
      setState(() {
        itemData = Map<String, dynamic>.from(event.snapshot.value as Map);
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(itemData?['title'] ?? 'Loading...'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlaceInformation(),
            SizedBox(height: 16),
            _buildReviewSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceInformation() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              itemData!['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey,
                  child: Icon(Icons.broken_image, color: Colors.white, size: 100),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          Text(
            itemData!['title'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Overview',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            itemData!['description']['Overview'],
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
          ),
          SizedBox(height: 16),
          Text(
            'Attractions',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          _buildAttractions(itemData!['description']['Attractions']),
          SizedBox(height: 16),
          Text(
            'Travel Tips',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          _buildTravelTips(itemData!['description']['Travel Tips']),
          SizedBox(height: 16),
          Text(
            'Conclusion',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            itemData!['description']['Conclusion'],
            style: TextStyle(fontSize: 16, height: 1.5, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Rating: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star,
                    color: index < (itemData!['rating'] ?? 0) ? Colors.orange : Colors.grey,
                    size: 20,
                  );
                }),
              ),
              SizedBox(width: 10),
              Text(
                itemData!['rating']?.toString() ?? 'N/A',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Likes: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Icon(Icons.favorite, color: Colors.red, size: 20),
              SizedBox(width: 5),
              Text(
                itemData!['likes']?.toString() ?? '0',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Comments',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          itemData!['comments'] != null
              ? _buildComments(itemData!['comments'])
              : Text('No comments yet'),
          SizedBox(height: 8),
          if (itemData!['comments'] != null) ...[
            InkWell(
              onTap: () {
                _showAllCommentsDialog(itemData!['comments']);
              },
              child: Text(
                'View all Comments',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAllCommentsDialog(Map<dynamic, dynamic>? comments) {
    if (comments == null) return;
    List<Map<dynamic, dynamic>> commentList = comments.values.toList().cast<Map<dynamic, dynamic>>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Comments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${commentList.length} Comments',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: commentList.length,
                    itemBuilder: (context, index) {
                      final comment = commentList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment['username'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                comment['comment'],
                                style: TextStyle(fontSize: 16, height: 1.5),
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
      },
    );
  }

  Widget _buildAttractions(Map<dynamic, dynamic>? attractions) {
    if (attractions == null) return Text('No attractions available');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attractions.keys.map((key) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$key: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: attractions[key],
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTravelTips(Map<dynamic, dynamic>? travelTips) {
    if (travelTips == null) return Text('No travel tips available');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: travelTips.keys.map((key) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$key: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: travelTips[key],
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildComments(Map<dynamic, dynamic> comments) {
    List<Map<dynamic, dynamic>> commentList = comments.values.toList().cast<Map<dynamic, dynamic>>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: commentList.take(3).map((comment) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment['username'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        comment['comment'],
                        style: TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

}

