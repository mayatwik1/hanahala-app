import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'business_create.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String uid;
  String? firstName;
  String? lastName;

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
          lastName = data['lastname'] ?? "";
        } else {
          firstName = "משתמש";
          lastName = "";
        }
      } catch (e) {
        print("שגיאה בקבלת נתוני המשתמש: $e");
        firstName = "שגיאה";
        lastName = "";
      }
    } else {
      uid = "No user logged in";
      firstName = "משתמש";
      lastName = "";
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // AppBar style header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Spacer(),
                    Text(
                      'הפרופיל שלי',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(flex: 2),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Profile section
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'שלום, $firstName $lastName',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 30),
              // Action Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildActionCard(
                      icon: Icons.add_business,
                      label: 'צור עסק משלך',
                      color: const Color.fromARGB(255, 0, 0, 0),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => BusinessCreationForm()),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    _buildActionCard(
                      icon: Icons.logout,
                      label: 'התנתק',
                      color: const Color.fromARGB(255, 0, 0, 0),
                      onPressed: () => logout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: Size(double.infinity, 50),
        elevation: 2,
      ),
    );
  }
}
