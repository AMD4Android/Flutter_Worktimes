// FirmenwechselScreen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirmenwechselScreen extends StatefulWidget {
  const FirmenwechselScreen({super.key});

  @override
  State<FirmenwechselScreen> createState() => _FirmenwechselScreenState();
}

class _FirmenwechselScreenState extends State<FirmenwechselScreen> {
  final TextEditingController _employer = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveEmployerName() async {
    String employerName = _employer.text;

    if (employerName.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_employer2', employerName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Change employer'.tr,
          style: TextStyle(fontSize: 28, color: Color(0xFFF4F5F4)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFF4F5F4),
          size: 30,
        ),
        backgroundColor: Colors.teal,toolbarHeight: 80,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            Text(
              'Please enter your new employer:'.tr,
              style: TextStyle(fontSize: 18, color: Color(0xFFF4F5F4)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _employer,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'New employer',
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color:Colors.teal,
                  ),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 350,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Setze die Ecken auf 0 für eckige Buttons
                    ),
                  ),
                  onPressed: () {
                    _saveEmployerName();
                    Navigator.pop(context); // Geht zurück zur vorherigen Seite
                  },
                  child:  Text(
                    'Save'.tr,
                    style: TextStyle(color: Colors.white, fontSize: 32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
