import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:worktimes_new/screens/zeiteintragung_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models&services/database_service.dart';
import 'localString.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _employer = TextEditingController();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isProgressRunning = true; // Steuert, ob die ProgressBar läuft

  @override
  void initState() {
    super.initState();
    _initializeAnimation(); // Initialisiere die Animation
  }

  @override
  void dispose() {
    DatabaseService.instance.close(); // Datenbankverbindung schließen
    _controller.dispose(); // AnimationController freigeben
    super.dispose();
  }

  // Initialisiere die Animation
  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  Future<void> _saveName() async {
    String employerName = _employer.text;
    String userName = _name.text;

    if (employerName.isNotEmpty || userName.isNotEmpty) {
      // Zugriff auf SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Speichern des Namens
      await prefs.setString('saved_userName', userName);
      await prefs.setString('saved_employer', employerName);

      // Stoppe die Animation
      setState(() {
        _isProgressRunning = false;
        _controller.stop();
      });

      // Navigieren zur Display-Seite
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const Zeiteintrag_Screen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0), // Höhe der AppBar
        child: AppBar(
          title: Align(
            alignment: const Alignment(0.0, 0.3), // Titel vertikal anpassen
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.work_history, color: Color(0xFFF4F5F4)),
                const SizedBox(width: 8), // Abstand zwischen Icon und Text
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 24, color: Color(0xFFF4F5F4)),
                ),
              ],
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Erste Zeile: Textfeld für Name
            Row(
              children: [
                const SizedBox(width: 30), // Abstand
                const Icon(Icons.person, color: Colors.white70),
                const SizedBox(width: 10), // Abstand
                SizedBox(
                  width: 250, // Setze die Breite für das Textfeld manuell
                  child: TextField(
                    controller: _name,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter your Name'.tr, // Platzhalter
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Abstand
            // Zweite Zeile: Textfeld für Firmenname
            Row(
              children: [
                const SizedBox(width: 30), // Abstand
                const Icon(Icons.business, color: Colors.white70), // Icon
                const SizedBox(width: 10), // Abstand
                SizedBox(
                  width: 250, // Setze die Breite für das Textfeld manuell
                  child: TextField(
                    controller: _employer,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Enter name of employer'.tr, // Platzhalter
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 64), // Abstand

            Align(
              alignment: const Alignment(-0.5, 0),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.black, // Schattenfarbe
                    backgroundColor: Colors.teal,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, // Eckige Buttons
                    ),
                  ),
                  onPressed: _saveName, // Asynchrone Methode aufrufen
                  child: Text(
                    'Save'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 64), // Abstand

            // Hier ist die animierte Progress-Bar
            Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width - 100, // Breite der ProgressBar
                height: 10, // Höhe der ProgressBar
                decoration: BoxDecoration(
                  color: Colors.grey.shade300, // Hintergrundfarbe
                  borderRadius: BorderRadius.circular(5), // Abgerundete Ecken
                ),
                child: Stack(
                  children: [
                    // Grüner beweglicher Teil
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Positioned(
                          left: _animation.value * (MediaQuery.of(context).size.width - 100), // Position des grünen Balkens
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 100) * 0.2, // Breite des grünen Teils (20% der Gesamtbreite)
                            height: 10, // Höhe des grünen Teils
                            decoration: BoxDecoration(
                              color: Colors.teal, // Farbe des grünen Teils
                              borderRadius: BorderRadius.circular(5), // Abgerundete Ecken
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}