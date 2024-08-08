import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:my_flutter_test2/pages/detail_page.dart';

class FavoritesTab extends StatefulWidget {
  @override
  _FavoritesTabState createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('favorites');
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _items = [];
  List<String> _locations = [];
  String? _selectedLocation;
  int _itemsPerPage = 5;
  int _lastLoadedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _fetchLocations();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
      _fetchData();
    }
  }

  Future<void> _loadCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('cached_items');
    final lastFetchDate = prefs.getString('last_fetch_date');

    if (cachedData != null && lastFetchDate != null) {
      final DateTime lastFetch = DateTime.parse(lastFetchDate);
      final DateTime now = DateTime.now();

      // Check if the cached data is from today
      if (lastFetch.day == now.day && lastFetch.month == now.month && lastFetch.year == now.year) {
        if (mounted) {
          setState(() {
            _items = List<Map<String, dynamic>>.from(json.decode(cachedData));
            _isLoading = false; // Stop loading if cached data is found
          });
        }
      }
    }
  }

  Future<void> _fetchLocations() async {
    DatabaseEvent event = await _database.once();
    List<String> tempLocations = [];
    for (var location in event.snapshot.children) {
      tempLocations.add(location.key!);
    }
    if (mounted) {
      setState(() {
        _locations = tempLocations;
        _selectedLocation = null; // Do not select any location by default
        _isLoading = false; // Stop loading after fetching locations
      });
    }
  }

  Future<void> _fetchData() async {
    if (_selectedLocation == null) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    DatabaseEvent event = await _database.child(_selectedLocation!)
        .orderByKey()
        .startAt('$_lastLoadedIndex')
        .limitToFirst(_itemsPerPage)
        .once();

    List<Map<String, dynamic>> tempList = [];
    for (var value in event.snapshot.children) {
      Map<String, dynamic> item = Map<String, dynamic>.from(value.value as Map);
      tempList.add(item);
    }

    if (mounted) {
      setState(() {
        _items.addAll(tempList);
        _items = _items.toSet().toList();  // Remove duplicates
        _lastLoadedIndex += _itemsPerPage;
        _isLoading = false;
      });

      // Cache the updated list and current date
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('cached_items', json.encode(_items));
      prefs.setString('last_fetch_date', DateTime.now().toIso8601String());
    }
  }

  void _onLocationChanged(String? newLocation) {
    if (newLocation != null) {
      if (mounted) {
        setState(() {
          _selectedLocation = newLocation;
          _items.clear();
          _lastLoadedIndex = 0;
          _isLoading = true; // Show loader while fetching new data
        });
      }
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text('Select a location'),
                      ),
                      ..._locations.map((String location) {
                        return DropdownMenuItem<String>(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: _onLocationChanged,
                  ),
                ),
                Expanded(
                  child: _selectedLocation == null
                      ? Center(child: Text('Please select a location'))
                      : ListView.builder(
                    controller: _scrollController,
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPage(
                                itemId: index,
                                location: _selectedLocation!,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(_items[index]['image'] ?? 'https://via.placeholder.com/150'),
                                  ),
                                  title: Text(_items[index]['title'] ?? 'No title', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                Image.network(
                                  _items[index]['image'] ?? 'https://via.placeholder.com/150',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    _items[index]['description'] != null ? _items[index]['description']['Overview'] ?? 'No description available' : 'No description available',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailPage(
                                            itemId: index,
                                            location: _selectedLocation!,
                                          ),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                    ),
                                    child: Text(
                                      'VIEW',
                                      style: TextStyle(color: Colors.black, fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Center(child: CircularProgressIndicator()), // Full screen loader
          ],
        );
      },
    );
  }
}
