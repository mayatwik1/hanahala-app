import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 this one is important
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Business {
  final String id;
  final String name;
  final String description;
  final String phone;
  final String ownerName;
  final String type;
  final String imageUrl;
  final List<String> images;
  final LatLng location;

  Business({
    required this.id,
    required this.name,
    required this.description,
    required this.phone,
    required this.ownerName,
    required this.type,
    required this.imageUrl,
    required this.images,
    required this.location,
  });

  factory Business.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final locationMap = data['location'] as Map<String, dynamic>?;

    return Business(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      phone: data['phone'] ?? '',
      ownerName: data['ownerName'] ?? '',
      type: data['type'] ?? 'Others',
      imageUrl: data['imageUrl'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      location: locationMap != null
          ? LatLng(locationMap['latitude'], locationMap['longitude'])
          : LatLng(0.0, 0.0),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'phone': phone,
      'ownerName': ownerName,
      'type': type,
      'imageUrl': imageUrl,
      'images': images,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
    };
  }
}

