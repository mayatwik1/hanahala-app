import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// This screen allows the user to pick a location on a Google Map.
/// Once a location is selected, a marker is shown, and the user can confirm the choice.
class BusinessLocationPicker extends StatefulWidget {
  @override
  _BusinessLocationPickerState createState() => _BusinessLocationPickerState();
}

class _BusinessLocationPickerState extends State<BusinessLocationPicker> {
  // This holds the location the user picks (latitude & longitude).
  LatLng? _pickedLocation;

  /// Called when the user taps anywhere on the map.
  /// Saves the tapped location and refreshes the UI to show the marker.
  void _onMapTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  /// Called when the user presses the confirm button.
  /// If a location is picked, it pops the screen and returns the LatLng.
  /// If no location is picked, shows a message asking the user to select one.
  void _confirmLocation() {
    if (_pickedLocation != null) {
      Navigator.pop(context, _pickedLocation); // Return the picked location to the previous screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('אנא בחר מיקום על המפה.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('בחר מיקום'), // AppBar title in Hebrew: "Choose location"
      ),
      body: Stack(
        children: [
          // The Google Map widget
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(31.7683, 35.2137), // Default location: Jerusalem
              zoom: 12,
            ),
            onTap: _onMapTap, // Set callback for when the map is tapped
            // If a location was picked, show a marker on that spot
            markers: _pickedLocation != null
                ? {
                    Marker(
                      markerId: MarkerId('picked-location'),
                      position: _pickedLocation!,
                    ),
                  }
                : {},
          ),

          // Confirm button at the bottom of the screen
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _confirmLocation, // When pressed, try to confirm the location
              child: Text('אשר מיקום'), // Button text in Hebrew: "Confirm location"
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color.fromARGB(255, 22, 52, 142),
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
