import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusinessLocationPicker extends StatefulWidget {
  @override
  _BusinessLocationPickerState createState() => _BusinessLocationPickerState();
}

class _BusinessLocationPickerState extends State<BusinessLocationPicker> {
  LatLng? _pickedLocation;

  void _onMapTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  void _confirmLocation() {
    if (_pickedLocation != null) {
      Navigator.pop(context, _pickedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location on the map.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('בחר מיקום'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(31.7683, 35.2137), // Default to Jerusalem
              zoom: 12,
            ),
            onTap: _onMapTap,
            markers: _pickedLocation != null
                ? {
                    Marker(
                      markerId: MarkerId('picked-location'),
                      position: _pickedLocation!,
                    ),
                  }
                : {},
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _confirmLocation,
              child: Text('אשר מיקום'),
            ),
          ),
        ],
      ),
    );
  }
}
