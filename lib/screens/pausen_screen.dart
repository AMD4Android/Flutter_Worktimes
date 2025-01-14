import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PausenScreen extends StatefulWidget {
  const PausenScreen({super.key});

  @override
  State<PausenScreen> createState() => _PausenScreenState();
}

class _PausenScreenState extends State<PausenScreen> {
  final TextEditingController fruhSchichtController = TextEditingController();
  final TextEditingController spatSchichtController = TextEditingController();
  final TextEditingController nachtSchichtController = TextEditingController();

  @override
  void dispose() {
    fruhSchichtController.dispose();
    spatSchichtController.dispose();
    nachtSchichtController.dispose();
    super.dispose();
  }

  // Funktion zum Speichern der Pausenwerte in SharedPreferences
  Future<void> _saveBreakTimes() async {
    final prefs = await SharedPreferences.getInstance();

    // Parse die Eingaben zu Integer, Standardwert ist 0, falls keine Eingabe
    int fruhPause = int.tryParse(fruhSchichtController.text) ?? 0;
    int spatPause = int.tryParse(spatSchichtController.text) ?? 0;
    int nachtPause = int.tryParse(nachtSchichtController.text) ?? 0;

    // Speichere die Pausenwerte in SharedPreferences
    await prefs.setInt('earlyShiftBreak', fruhPause);
    await prefs.setInt('lateShiftBreak', spatPause);
    await prefs.setInt('nightShiftBreak', nachtPause);

    // Rückmeldung an den Benutzer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Break times saved successfully!'.tr)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Insert breaks'.tr,
          style: TextStyle(fontSize: 28, color: Color(0xFFF4F5F4)),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFF4F5F4),
          size: 30,
        ),
        backgroundColor: Colors.teal,toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            // Frühschicht Pausenzeiten
            Text(
              'Early shift break'.tr,
              style: const TextStyle(fontSize: 18, color: Color(0xFFF4F5F4)),
            ),
            SizedBox(
              child: TextField(
                controller: fruhSchichtController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 30',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:Colors.teal,
                      ),
                    )
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            // Spätschicht Pausenzeiten
            Text('Late shift break'.tr,
              style: const TextStyle(fontSize: 18, color: Color(0xFFF4F5F4)),
            ),
            SizedBox(
              child: TextField(
                controller: spatSchichtController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 30',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:Colors.teal,
                      ),
                    )
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            // Nachtschicht Pausenzeiten
            Text(
              'Night shift break'.tr,
              style: const TextStyle(fontSize: 18, color: Color(0xFFF4F5F4)),
            ),
            SizedBox(
              child: TextField(
                controller: nachtSchichtController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'e.g. 30',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:Colors.teal,
                      ),
                    )
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.black, thickness: 2),
            const SizedBox(height: 46),
            // Button zur Bestätigung
            Center(
              child: SizedBox(
                width: 350,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.black,
                    backgroundColor: Colors.teal,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: _saveBreakTimes,
                  child:  Text(
                    'Save'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 32),
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
