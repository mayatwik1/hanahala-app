import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime date;
  final String creatorId;
  final String creatorName;
  final String? imageUrl;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.creatorId,
    required this.creatorName,
    this.imageUrl,
  });

  /// יצירת אובייקט Event מתוך מסמך Firestore
  factory Event.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id, // מזהה המסמך (לא מתוך data)
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      imageUrl: data['imageUrl'],
    );
  }

  /// המרה של האובייקט למפה לשמירה ב-Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'date': date.toIso8601String(), // תואם בדיוק למה שאת שומרת
      'creatorId': creatorId,
      'creatorName': creatorName,
      'imageUrl': imageUrl,
    };
  }
}
