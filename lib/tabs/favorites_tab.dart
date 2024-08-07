import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _fetchLocations() async {
    DatabaseEvent event = await _database.once();
    List<String> tempLocations = [];
    for (var location in event.snapshot.children) {
      tempLocations.add(location.key!);
    }
    setState(() {
      _locations = tempLocations;
      _selectedLocation = _locations.isNotEmpty ? _locations.first : null;
      if (_selectedLocation != null) {
        _fetchData();
      }
    });
  }

  void _fetchData() async {
    if (_selectedLocation == null) return;

    setState(() {
      _isLoading = true;
    });

    _database.child(_selectedLocation!).orderByKey().startAt('$_lastLoadedIndex').limitToFirst(_itemsPerPage).once().then((DatabaseEvent event) {
      List<Map<String, dynamic>> tempList = [];
      for (var value in event.snapshot.children) {
        Map<String, dynamic> item = Map<String, dynamic>.from(value.value as Map);
        tempList.add(item);
      }
      setState(() {
        _items.addAll(tempList);
        _lastLoadedIndex += _itemsPerPage;
        _isLoading = false;
      });
    });
  }

  void _onLocationChanged(String? newLocation) {
    if (newLocation != null) {
      setState(() {
        _selectedLocation = newLocation;
        _items.clear();
        _lastLoadedIndex = 0;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(

      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButtonFormField<String>(
            value: _selectedLocation,
            items: _locations.map((String location) {
              return DropdownMenuItem<String>(
                value: location,
                child: Text(location),
              );
            }).toList(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            onChanged: _onLocationChanged,
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPage(
                        itemId: index, // Assuming you have a unique identifier for each item
                        location: _selectedLocation!,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Image
                          Image.network(
                            _items[index]['image'],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey,
                                child: Icon(Icons.broken_image, color: Colors.white),
                              );
                            },
                          ),
                          SizedBox(width: 10),
                          // Column with title, description, and rating
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _items[index]['title'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  _items[index]['description']['Overview'],
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Icon(
                                      Icons.star,
                                      size: 20,
                                      color: starIndex < _items[index]['rating']
                                          ? Colors.orange
                                          : Colors.grey,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
