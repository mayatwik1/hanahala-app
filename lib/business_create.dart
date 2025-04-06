import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'location_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class BusinessCreationForm extends StatefulWidget {
  @override
  _BusinessCreationFormState createState() => _BusinessCreationFormState();
}

class _BusinessCreationFormState extends State<BusinessCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _selectedType = 'בית קפה';
  List<String> businessTypes = [
    'בית קפה', 'מכולת', 'סופרמרקט', 'חנות בגדים', 'חדר כושר', 'מספרה',
    'בית מרקחת', 'חנות צעצועים', 'אלקטרוניקה', 'חנות ספרים', 'מאפייה',
    'חדר בריחה', 'חנות רהיטים', 'לק ג\'ל', 'עיצוב גבות', 'קוסמטיקה',
  ];

  List<String> _imagePaths = [];
  LatLng? _selectedLocation;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imagePaths = pickedFiles.map((file) => file.path).toList();
      });
    }
  }

  Future<void> _createBusiness() async {
    if (!_formKey.currentState!.validate() || _imagePaths.isEmpty || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('נא למלא את כל השדות ולהעלות תמונות')),
      );
      return;
    }

    List<String> imageUrls = await _uploadImagesToFirebase(_imagePaths);
    if (imageUrls.isEmpty) return;

    final businessData = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'phone': _phoneController.text,
      'type': _selectedType,
      'location': {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      },
      'imageUrls': imageUrls,
    };

    try {
      await FirebaseFirestore.instance.collection('businesses').add(businessData);
      Navigator.pop(context);
    } catch (e) {
      print("Error saving business: $e");
    }
  }

  Future<List<String>> _uploadImagesToFirebase(List<String> imagePaths) async {
    List<String> urls = [];
    for (String path in imagePaths) {
      File file = File(path);
      img.Image? image = img.decodeImage(file.readAsBytesSync());
      if (image != null) {
        final resized = img.copyResize(image, width: 800, height: 800);
        final compressed = img.encodeJpg(resized, quality: 85);
        final ref = FirebaseStorage.instance
            .ref()
            .child('business_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putData(Uint8List.fromList(compressed));
        urls.add(await ref.getDownloadURL());
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        body: Column(
          children: [
            Container(
              height: 100,
              padding: const EdgeInsets.only(top: 40, right: 16, left: 16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 72, 163, 228),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Spacer(),
                  Text(
                    'צור עסק חדש',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(flex: 2),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildCard(
                        title: 'פרטי העסק',
                        children: [
                          _buildTextField(_nameController, 'שם העסק'),
                          SizedBox(height: 12),
                          _buildTextField(_descriptionController, 'תיאור העסק', maxLines: 4),
                          SizedBox(height: 12),
                          _buildTextField(_phoneController, 'מספר טלפון', inputType: TextInputType.phone),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildCard(
                        title: 'סוג עסק',
                        children: [
                          DropdownButtonFormField<String>(
                            value: _selectedType,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                            onChanged: (value) {
                              if (value != null) setState(() => _selectedType = value);
                            },
                            items: businessTypes.map((type) {
                              return DropdownMenuItem(value: type, child: Text(type));
                            }).toList(),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildCard(
                        title: 'מיקום',
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BusinessLocationPicker()),
                                );
                                if (result != null && result is LatLng) {
                                  setState(() => _selectedLocation = result);
                                }
                              },
                              icon: Icon(Icons.location_pin),
                              label: Text('בחר מיקום'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 72, 163, 228),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),

                          if (_selectedLocation != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'מיקום נבחר: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                                style: TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildCard(
                        title: 'תמונות',
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _pickImages,
                              icon: Icon(Icons.image),
                              label: Text('העלה תמונות'),
                            ),
                          ),
                          if (_imagePaths.isNotEmpty)
                            Container(
                              height: 100,
                              margin: EdgeInsets.only(top: 12),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _imagePaths.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.symmetric(horizontal: 6),
                                    width: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(File(_imagePaths[index])),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _createBusiness,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 72, 163, 228),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: Text(
                            'צור עסק',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}


  Widget _buildTextField(TextEditingController controller, String hint,
      {int maxLines = 1, TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      maxLines: maxLines,
      keyboardType: inputType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      validator: (value) => value == null || value.isEmpty ? 'שדה חובה' : null,
    );
  }
}
