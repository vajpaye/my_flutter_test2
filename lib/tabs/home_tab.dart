import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';  // For JSON encoding and decoding
import 'package:my_flutter_test2/pages/review_page.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('favorites');
  final FocusNode _focusNode = FocusNode();
  List<String> _locations = [];
  Map<String, List<Map<String, dynamic>>> _placesByLocation = {};
  List<Map<String, dynamic>> _filteredPlaces = [];
  String _searchQuery = '';
  bool _isSearchFocused = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchLocations();
    _focusNode.addListener(() {
      setState(() {
        _isSearchFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_places');
    if (cachedData != null) {
      setState(() {
        _placesByLocation = Map<String, List<Map<String, dynamic>>>.from(json.decode(cachedData));
        _filteredPlaces = _placesByLocation.entries.expand((entry) => entry.value).toList();
        _isLoading = false;  // Data is loaded from cache
      });
    }
  }

  Future<void> _fetchLocations() async {
    DatabaseEvent event = await _database.once();
    List<String> tempLocations = [];
    for (var location in event.snapshot.children) {
      tempLocations.add(location.key!);
      await _fetchPlaces(location.key!);
    }
    if (mounted) {
      setState(() {
        _locations = tempLocations;
        _filteredPlaces = _placesByLocation.entries.expand((entry) => entry.value).toList();
        _isLoading = false; // Data fetching completed
      });
    }

    // Cache the data
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('cached_places', json.encode(_placesByLocation));
  }

  Future<void> _fetchPlaces(String location) async {
    DatabaseEvent event = await _database.child(location).once();
    List<Map<String, dynamic>> tempPlaces = [];
    int count = 0;
    for (var place in event.snapshot.children) {
      if (count >= 2) break; // Limit to 2 places
      Map<String, dynamic> placeData = Map<String, dynamic>.from(place.value as Map);
      if (placeData.containsKey('title')) {
        tempPlaces.add({
          'key': place.key!,
          'location': location,
          'title': placeData['title'],
          'image': placeData['description']['image']
        });
        count++;
      }
    }
    _placesByLocation[location] = tempPlaces;
  }

  void _filterPlaces(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _filteredPlaces = _placesByLocation.entries.expand((entry) => entry.value).toList();
      } else {
        _filteredPlaces = _placesByLocation.entries.expand((entry) => entry.value).where((place) {
          return place['title'].toLowerCase().contains(_searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
      },
      child: Scaffold(
        body: _isLoading && _placesByLocation.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search for a place',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                ),
                style: TextStyle(color: Colors.black),
                onChanged: _filterPlaces,
              ),
              SizedBox(height: 20),
              _isSearchFocused
                  ? Expanded(
                child: _filteredPlaces.isNotEmpty
                    ? ListView.builder(
                  itemCount: _filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = _filteredPlaces[index];
                    return ListTile(
                      title: Text(
                        place['title'],
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewPage(
                              location: place['location'],
                              placeKey: place['key'],
                              placeTitle: place['title'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
                    : Center(
                  child: Text(
                    'No places found',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              )
                  : Container(),
              if (!_isSearchFocused)
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ..._placesByLocation.entries.expand((entry) => entry.value).take(2).map((place) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      place['image'] ?? 'https://via.placeholder.com/150',
                                      width: MediaQuery.of(context).size.width * 0.25,
                                      height: MediaQuery.of(context).size.width * 0.25,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place['title'],
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ReviewPage(
                                                  location: place['location'],
                                                  placeKey: place['key'],
                                                  placeTitle: place['title'],
                                                ),
                                              ),
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, color: Colors.black),
                                              SizedBox(width: 5),
                                              Text(
                                                'Write a review',
                                                style: TextStyle(color: Colors.black, fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        SizedBox(height: 20),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Is SumoVista missing a place?',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Tell us about it so we can improve what we show.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Add functionality to add a missing place
                                },
                                icon: Icon(Icons.location_on, color: Colors.white),
                                label: Text('Add a missing place'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black, // Button color
                                  foregroundColor: Colors.white, // Text color
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
