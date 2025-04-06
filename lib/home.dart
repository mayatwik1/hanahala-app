import 'package:flutter/material.dart';
import 'package:hanahala3/business_map.dart';
import 'package:hanahala3/businesses.dart';
import 'package:hanahala3/calander_page.dart';
import 'package:hanahala3/tabbed_business.dart';
import 'package:hanahala3/tabbed_events_page.dart';
import 'package:hanahala3/user_profile_page.dart';
import 'events.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  late String uid;
  String? firstName;

  @override
  Future<void> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      try {
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          var data = userDoc.data() as Map<String, dynamic>;
          firstName = data['firstname'] ?? "משתמש";
        } else {
          firstName = "משתמש";
        }
      } catch (e) {
        print("Error fetching user data: $e");
        firstName = "שגיאה";
      }
    } else {
      uid = "No user logged in";
      firstName = "משתמש";
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar with greeting and profile button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Greeting texts
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'שלום, $firstName!',
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'גלה את השכונה שלך',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      // Profile button on the left
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: const Color.fromARGB(255, 54, 188, 250),
                          radius: 28.0,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    itemCount: tiles.length,
                    itemBuilder: (context, index) {
                      final tile = tiles[index];
                      return _buildTile(
                        context,
                        title: tile.title,
                        color: tile.color,
                        icon: tile.icon,
                        onTap: tile.onTap,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required String title,
    required Color color,
    required IconData icon,
    required void Function(BuildContext) onTap,
  }) {
    return GestureDetector(
      onTap: () => onTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 6.0,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              left: -10,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft, // <-- icon now on the left
                    child: Icon(
                      icon,
                      size: 24.0,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated tiles list
class Tile {
  final String title;
  final Color color;
  final IconData icon;
  final void Function(BuildContext) onTap;

  Tile({
    required this.title,
    required this.color,
    required this.icon,
    required this.onTap,
  });
}

final List<Tile> tiles = [
  Tile(
    title: 'מורים\n פרטיים',
    color: const Color.fromARGB(255, 159, 225, 255),
    icon: Icons.school,
    onTap: (context) {
      print("אין פעולה זמינה");
    },
  ),
  Tile(
    title: 'עסקים \n מקומיים',
    color: const Color.fromARGB(255, 149, 217, 179),
    icon: Icons.store,
    onTap: (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BusinessesTabbedPage(),
        ),
      );
    },
  ),
  Tile(
    title: 'מציאת בייביסיטר',
    color: const Color.fromARGB(255, 120, 159, 255),
    icon: Icons.baby_changing_station,
    onTap: (context) {
      print("אין פעולה זמינה");
    },
  ),
  Tile(
    title: 'אירועים',
    color: const Color.fromARGB(255, 197, 175, 233),
    icon: Icons.event,
    onTap: (context) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TabbedEventsPage(),
        ),
      );
    },
  ),
  Tile(
    title: 'אבידות \n ומציאות',
    color: const Color.fromARGB(255, 253, 184, 207),
    icon: Icons.search,
    onTap: (context) {
      print("אין פעולה זמינה");
    },
  ),
  Tile(
    title: 'השאלה ועזרה',
    color: const Color.fromARGB(255, 255, 154, 154),
    icon: Icons.volunteer_activism,
    onTap: (context) {
      print("אין פעולה זמינה");
    },
  ),
];
