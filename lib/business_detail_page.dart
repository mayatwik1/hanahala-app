import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusinessDetailPage extends StatelessWidget {
  final String businessId;

  BusinessDetailPage({required this.businessId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('businesses')
            .doc(businessId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('שגיאה: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('העסק לא נמצא'));
          }

          final business = snapshot.data!;
          final name = business['name'] ?? 'ללא שם';
          final type = business['type'] ?? 'סוג לא מוגדר';
          final description = business['description'] ?? 'אין תיאור';
          final phone = business['phone'] ?? 'לא זמין';
          final location = business['location'] as Map<String, dynamic>?;
          final imageUrls = business['imageUrls'] as List? ?? [];

          LatLng? businessLocation;
          if (location != null && location.containsKey('latitude') && location.containsKey('longitude')) {
            businessLocation = LatLng(location['latitude'], location['longitude']);
          }

          return Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 173, 210, 228),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(50),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(color: Colors.white),
                  ),
                ],
              ),
              Positioned(
                top: 40,
                left: 16,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 20,
                right: 20,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: imageUrls.isNotEmpty
                      ? PageView.builder(
                          itemCount: imageUrls.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                imageUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            'אין תמונות זמינות',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.40,
                left: 0,
                right: 0,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(16),
                          child: Text(
                            description,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color.fromARGB(255, 0, 0, 0),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 148, 192, 213),
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text(
                                        'מספר טלפון: $phone',
                                        textDirection: TextDirection.rtl,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('סגור'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              iconSize: 50,
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 148, 192, 213),
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              onPressed: () {},
                              iconSize: 50,
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 148, 192, 213),
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(10),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              onPressed: () {
                                print('Open Instagram');
                              },
                              iconSize: 50,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'מיקום העסק',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 8),
                        if (businessLocation != null)
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: businessLocation,
                                  zoom: 15,
                                ),
                                markers: {
                                  Marker(
                                    markerId: MarkerId('business-location'),
                                    position: businessLocation,
                                  ),
                                },
                              ),
                            ),
                          )
                        else
                          Text(
                            'מיקום לא זמין',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


