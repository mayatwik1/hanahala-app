import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'business_detail_page.dart';

class BusinessesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('businesses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final businesses = snapshot.data!.docs;
          Map<String, List> categorizedBusinesses = {};

          for (var business in businesses) {
            final type = business['type'] ?? 'אחרים';
            if (!categorizedBusinesses.containsKey(type)) {
              categorizedBusinesses[type] = [];
            }
            categorizedBusinesses[type]!.add(business);
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
            itemCount: categorizedBusinesses.keys.length,
            itemBuilder: (context, index) {
              final category = categorizedBusinesses.keys.elementAt(index);
              final categoryBusinesses = categorizedBusinesses[category]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Row(
                        textDirection: TextDirection.rtl,
                        children: categoryBusinesses.map<Widget>((business) {
                          // Safely handle the 'imageUrls' field
                          final imageUrls = (business['imageUrls'] as List?)?.cast<String>() ?? [];
                          final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : null;

                          return InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BusinessDetailPage(
                                  businessId: business.id,
                                ),
                              ),
                            ),
                            child: Container(
                              width: 200,
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(12.0),
                                          ),
                                          child: Image.network(
                                            imageUrl,
                                            fit: BoxFit.cover,
                                            height: 120,
                                            width: 200,
                                            loadingBuilder: (context, child, progress) {
                                              if (progress == null) return child;
                                              return Container(
                                                height: 120,
                                                width: 200,
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: CircularProgressIndicator(
                                                    value: progress.expectedTotalBytes != null
                                                        ? progress.cumulativeBytesLoaded /
                                                            (progress.expectedTotalBytes ?? 1)
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            },
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 120,
                                                width: 200,
                                                color: Colors.grey[200],
                                                child: Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 40,
                                                    color: Colors.red[400],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Container(
                                          height: 120,
                                          width: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(12.0),
                                            ),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.store,
                                              size: 50,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      business['name'] ?? 'ללא שם',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
