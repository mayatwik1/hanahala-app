import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'business_detail_page.dart';

// Define the BusinessMapPage StatefulWidget
class BusinessMapPage extends StatefulWidget {
  @override
  _BusinessMapPageState createState() => _BusinessMapPageState();
}

// Define the _BusinessMapPageState class
class _BusinessMapPageState extends State<BusinessMapPage> {
  // Late initialization of GoogleMapController
  late GoogleMapController _mapController;
  // List to hold markers
  final List<Marker> _markers = [];
  // Initial position of the map
  final LatLng _initialPosition = LatLng(31.9716, 34.7925); // Default to Rishon LeZion
  // Variables to hold selected business information
  String? _selectedBusinessId;
  String? _selectedBusinessName;
  LatLng? _selectedMarkerPosition;

  // Flag to control map interaction
  bool _mapInteractionEnabled = true;

  @override
  void initState() {
    super.initState();
    // Load business locations when the widget is initialized
    _loadBusinessLocations();
  }

  // Function to load business locations from Firestore
  Future<void> _loadBusinessLocations() async {
    try {
      // Fetch all documents from the 'businesses' collection
      final querySnapshot =
          await FirebaseFirestore.instance.collection('businesses').get();

      // Iterate through each document in the snapshot
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        // Extract location from the document data
        final location = data['location'] as Map<String, dynamic>?;
        if (location != null) {
          // Create a LatLng object from the location data
          final LatLng position =
              LatLng(location['latitude'], location['longitude']);
          // Add a marker to the list of markers
          _markers.add(
            Marker(
              markerId: MarkerId(doc.id),
              position: position,
              onTap: () {
                // Update the selected business information when a marker is tapped
                setState(() {
                  _selectedMarkerPosition = position;
                  _selectedBusinessName = data['name'] ?? 'ללא שם';
                  _selectedBusinessId = doc.id;
                });
              },
            ),
          );
        }
      }
      // Update the UI with the new markers
      setState(() {});
    } catch (e) {
      // Log any errors encountered while loading business locations
      print('Error loading business locations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Stack(
        children: [
          // AbsorbPointer to control map interaction
          AbsorbPointer(
            absorbing: !_mapInteractionEnabled, // Enable or disable interaction
            child: GestureDetector(
              onTap: () {
                // Enable map interaction on tap
                setState(() {
                  _mapInteractionEnabled = true;
                });
              },
              child: GoogleMap(
                // Initial camera position
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 12,
                ),
                // Set of markers to display on the map
                markers: Set<Marker>.of(_markers),
                // Function to call when the map is created
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                // Function to call when the map is tapped
                onTap: (_) {
                  setState(() {
                    _selectedMarkerPosition = null;
                  });
                },
              ),
            ),
          ),
          // Display a card with business details if a marker is selected
          if (_selectedMarkerPosition != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Card(
                elevation: 8,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Display the selected business name
                      Text(
                        _selectedBusinessName ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      // Button to view business details
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedBusinessId != null) {
                              // Navigate to the BusinessDetailPage
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BusinessDetailPage(
                                    businessId: _selectedBusinessId!,
                                  ),
                                ),
                              );
                            } else {
                              print('Business ID is null');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('צפה בפרטים', textDirection: TextDirection.rtl),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

