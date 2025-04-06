import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  File? _selectedImage;
  DateTime? _selectedDate;
  late String uid;
  final user = FirebaseAuth.instance.currentUser;
  late String displayName;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      uid = user!.uid;
      displayName = user!.displayName ?? "אורח";
    } else {
      uid = "No user logged in";
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final originalImage = img.decodeImage(image.readAsBytesSync());
      if (originalImage == null) throw Exception("Failed to decode image.");
      final resizedImage = img.copyResize(originalImage, width: 800);
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('event_images/$fileName.jpg');
      await ref.putData(Uint8List.fromList(compressedBytes));
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _createEvent() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedImage == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("נא למלא את כל השדות, לבחור תאריך ולהעלות תמונה.")),
      );
      return;
    }

    final imageUrl = await _uploadImageToFirebase(_selectedImage!);
    if (imageUrl == null) return;

    final newEvent = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'date': _selectedDate!.toIso8601String(),
      'imageUrl': imageUrl,
      'creatorId': uid,
      'creatorName': displayName,
    };

    try {
      await FirebaseFirestore.instance.collection('events').add(newEvent);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("האירוע נוצר בהצלחה!")),
      );
      Navigator.pop(context);
    } catch (e) {
      print("שגיאה ביצירת אירוע: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('יצירת אירוע', style: TextStyle(color: Colors.black, fontSize: 24)),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildLabel('שם האירוע'),
              _buildInput(_titleController, 'לדוגמה: פיקניק בפארק'),
              _buildLabel('מיקום'),
              _buildInput(_locationController, 'איפה האירוע יתקיים?'),
              _buildLabel('תיאור'),
              _buildInput(_descriptionController, 'פרטים נוספים...', maxLines: 3),
              const SizedBox(height: 20),
              _buildDateButton(),
              const SizedBox(height: 12),
              _buildImagePicker(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 12),
    child: Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        textAlign: TextAlign.right,
      ),
    ),
  );
}


  Widget _buildInput(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[200],
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(Icons.calendar_today, color: Colors.black),
        onPressed: _pickDate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        label: Text(
          _selectedDate == null
              ? 'בחר תאריך ושעה'
              : 'תאריך שנבחר: ${_selectedDate!.toLocal()}',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return _selectedImage == null
        ? SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: Icon(Icons.image, color: Colors.black),
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              label: Text('העלה תמונה'),
            ),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              _selectedImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _createEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 22, 52, 142),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text('צור אירוע', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
