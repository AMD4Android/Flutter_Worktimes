import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worktimes_new/screens/firmenwechsel_screen.dart';
import 'package:worktimes_new/screens/pausen_screen.dart';
import '../models&services/database_service.dart';
import 'listview_screen.dart';
import 'lohnberechnungs_screen.dart';

class Zeiteintrag_Screen extends StatefulWidget {
  const Zeiteintrag_Screen({
    super.key,
  });

  @override
  State<Zeiteintrag_Screen> createState() => _Zeiteintrag_ScreenState();
}

class _Zeiteintrag_ScreenState extends State<Zeiteintrag_Screen> {
  DateTime selectedStartTime = DateTime.now();
  DateTime selectedEndTime = DateTime.now();
  String startTimeText = 'No time selected'.tr;
  String endTimeText = 'No time selected'.tr;
  String shiftType = 'Early'.tr;
  String startTimeEntry = '';
  String endTimeEntry = ''; // Standard-Shift-Typ
  String userName = '';
  String employerName = "";
  String startTimeUebertragung = 'Select Start Time'.tr;
  String endTimeUebertragung = 'Select End Time'.tr;
  Map<String, String> entry = {};
  int earlyShiftBreak = 0;
  int lateShiftBreak = 0;
  int nightShiftBreak = 0;
  bool _isPressedButton1 = false; // Zustand für Button 1
  bool _isPressedButton2 = false; // Zustand für Button 2
  String language = 'English';
  String localeCode = 'en_US';
  // Dummy-Liste zum Speichern der Einträge
  List<Map<String, String>> entries = [];

  // Radio-Button Auswahl aktualisieren
  void _selectShift(String? value) {
    setState(() {
      shiftType = value ?? 'Early'; // Falls `null`, setzen wir Standardwert
    });
  }

  // Liste der Wochentage
  final List<String> weekdays = [
    'Monday'.tr,
    'Tuesday'.tr,
    'Wednesday'.tr,
    'Thursday'.tr,
    'Friday'.tr,
    'Saturday'.tr,
    'Sunday'.tr
  ];

  // Liste der Monate
  final List<String> months = [
    'January'.tr,
    'February'.tr,
    'March'.tr,
    'April'.tr,
    'May'.tr,
    'June'.tr,
    'July'.tr,
    'August'.tr,
    'September'.tr,
    'October'.tr,
    'November'.tr,
    'December'.tr
  ];

  // Allgemeine Funktion zum Anzeigen des CupertinoDatePickers
  void _showCupertinoTimePicker(BuildContext context, String pickerType) {
    DateTime initialTime =
    pickerType == 'start' ? selectedStartTime : selectedEndTime;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 270,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: initialTime,
                mode: CupertinoDatePickerMode.dateAndTime,
                use24hFormat: true, // 24-Stunden-Format
                onDateTimeChanged: (DateTime newTime) {
                  setState(() {
                    if (pickerType == 'start') {
                      selectedStartTime = newTime;
                    } else {
                      selectedEndTime = newTime;
                    }
                  });
                },
              ),
            ),
            CupertinoButton(
              child:  Text('Done'.tr),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  String weekday = pickerType == 'start'
                      ? weekdays[selectedStartTime.weekday - 1]
                      : weekdays[selectedEndTime.weekday - 1];
                  String month = pickerType == 'start'
                      ? months[selectedStartTime.month - 1]
                      : months[selectedEndTime.month - 1];
                  String minute = (pickerType == 'start'
                      ? selectedStartTime.minute
                      : selectedEndTime.minute)
                      .toString()
                      .padLeft(2, '0'); // Minuten mit führender Null
                  String hours = (pickerType == 'start'
                      ? selectedStartTime.hour
                      : selectedEndTime.hour)
                      .toString()
                      .padLeft(2, '0');

                  if (pickerType == 'start') {
                    startTimeText =
                    "Start: \n${weekday}, ${selectedStartTime.day}. ${month} $hours:$minute";
                    startTimeEntry = "$hours:$minute";
                    startTimeUebertragung = "$hours:$minute";
                  } else {
                    endTimeText =
                    "Ende: \n${weekday}, ${selectedEndTime.day}. ${month} $hours:$minute";
                    endTimeEntry = "$hours:$minute";
                    endTimeUebertragung = "$hours:$minute";
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // Abruf der Pausen
  Future<void> loadBreakTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      earlyShiftBreak = prefs.getInt('earlyShiftBreak') ?? 0;
      lateShiftBreak = prefs.getInt('lateShiftBreak') ?? 0;
      nightShiftBreak = prefs.getInt('nightShiftBreak') ?? 0;
    });
  }

  // Berechnung der Differenz zwischen Startzeit und Endzeit
  String calculateTimeDifference() {
    if (endTimeEntry != "") {
      Duration difference;

      // Spezielle Berechnung für Nachtschichten
      if (shiftType == 'Night') {
        // Wenn die Endzeit vor der Startzeit liegt (über Mitternacht hinaus)
        if (selectedEndTime.isBefore(selectedStartTime)) {
          // Addiere einen Tag zur Endzeit
          DateTime adjustedEndTime = selectedEndTime.add(Duration(days: 1));
          difference = adjustedEndTime.difference(selectedStartTime);
        } else {
          difference = selectedEndTime.difference(selectedStartTime);
        }
      } else {
        // Normale Berechnung für andere Schichttypen
        difference = selectedEndTime.difference(selectedStartTime);
      }

      // Pausenzeit in Minuten basierend auf dem Schichttyp
      int breakMinutes = 0;
      if (shiftType == 'Early') {
        breakMinutes = earlyShiftBreak;
      } else if (shiftType == 'Late') {
        breakMinutes = lateShiftBreak;
      } else if (shiftType == 'Night') {
        breakMinutes = nightShiftBreak;
      }

      // Arbeitszeit abzüglich Pausenzeit
      Duration adjustedDifference;

      if (difference > const Duration(hours: 6)) {
        adjustedDifference = difference - Duration(minutes: breakMinutes);
      } else {
        adjustedDifference = difference; // oder eine andere Logik, falls gewünscht
      }

      // Berechne Stunden und Minuten aus der angepassten Differenz
      int hours = adjustedDifference.inHours;
      int minutes = adjustedDifference.inMinutes % 60;

      // Rückgabe des formatierten Ergebnisses
      return "${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m";
    } else {
      return "00h:00m";
    }
  }

  void handlePress(int buttonIndex) {
    setState(() {
      if (buttonIndex == 1) {
        _isPressedButton1 = true; // Button 1 wird gedrückt
      } else if (buttonIndex == 2) {
        _isPressedButton2 = true; // Button 2 wird gedrückt
      }
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        if (buttonIndex == 1) {
          _isPressedButton1 = false; // Button 1 wird losgelassen
        } else if (buttonIndex == 2) {
          _isPressedButton2 = false; // Button 2 wird losgelassen
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadName();
    loadBreakTimes();

    //_deleteName();
  }

  Future<void> _deleteName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_employer');
    await prefs.remove('saved_employer2'); // Entfernt den gespeicherten Namen
  }

  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Abrufen des Namens
    setState(() {
      userName = prefs.getString('saved_userName') ?? "No name saved!";
      _loadEmployerName();
    });
  }

  Future<void> _loadEmployerName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String newCoName = prefs.getString('saved_employer2').toString();
    String altCoName = prefs.getString('saved_employer').toString();
    employerName = newCoName == "null" ? altCoName : newCoName;
  }

  // Eintrag hinzufügen und zu ListviewScreen navigieren
  Future<void> _addEntry() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String newCoName = prefs.getString('saved_employer2').toString();
      String altCoName = prefs.getString('saved_employer').toString();
      employerName = newCoName == "null" ? altCoName : newCoName;

      String duration = calculateTimeDifference();
      //String date = "${selectedStartTime.year}-${selectedStartTime.month}-${selectedStartTime.day}";
      String date = DateFormat('dd.MM.yyyy')
          .format(selectedStartTime); // Konvertierung zu dd.mm.yyyy

      try {
        entry = {
          'employer': employerName,
          'date': date,
          'start': startTimeEntry,
          'end': endTimeEntry,
          'duration': duration,
          'shift': shiftType,
        };
      }
      catch (e) {
        print('Ein Fehler ist aufgetreten: $e');
      } finally {
        print('Dies wird immer ausgeführt.');
      }
    });
    try {
      await DatabaseService.instance.insertEntry(entry);

    } catch (e) {
      print('Zeile: 280. Ein Fehler ist aufgetreten: $e' );
    } finally {
      print('Dies wird immer ausgeführt.');
    }
    // In die Datenbank einfügen
  }

// Methode zum Ändern und Speichern der Sprache
  Future<void> updateLanguage(String localeCode) async {
    // Teile das localeCode in Sprach- und Regions-Teile auf
    var localeParts = localeCode.split('_');
    Locale newLocale = Locale(localeParts[0], localeParts[1]);

    // Aktualisiere die Sprache in der App
    Get.updateLocale(newLocale);

    // Speichere die Sprache in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', localeCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(height: 56),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 0),
            Container(
              color: Colors.teal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Time entry'.tr,
                      style: const TextStyle(
                        fontSize: 30,
                        color: Color(0xFFF4F5F4),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert, // oder ein anderes Icon
                      color: Colors.white, // Die gewünschte Farbe
                      size: 30, // Die gewünschte Größe
                    ),
                    onSelected: (String value) {
                      setState(() {
                        // Hier können wir auf den gewählten Menüpunkt reagieren
                        print("Gewähltes Menüelement: $value");
                        switch (value) {
                          case "pausen":
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const PausenScreen()),
                              //MaterialPageRoute(builder: (context) => const TimePickerScreen()),
                            );
                            break;
                          case "employer":
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const FirmenwechselScreen()),
                            );
                            break;
                          case "lohn":
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const LohnabrechnungsScreen()),
                            );
                            break;
                          case "sprache":
                            showPopup(context);
                        }
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'pausen',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // Minimale Breite
                            children: [
                              SizedBox(
                                width: 120,
                                // Hier die gewünschte Breite festlegen
                                child: Text(
                                  'Add breaks'.tr,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Icon(Icons.free_breakfast, color: Colors.teal),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'employer',
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Minimale Breite
                            children: [
                              SizedBox(
                                width: 120,
                                // Hier die gewünschte Breite festlegen
                                child: Text(
                                  'Change employer'.tr,
                                  style:const  TextStyle(color: Colors.white),
                                ),
                              ),
                              Icon(Icons.change_circle, color: Colors.teal),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'lohn',
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Minimale Breite
                            children: [
                              SizedBox(
                                width: 120,
                                // Hier die gewünschte Breite festlegen
                                child: Text(
                                  'Wage calculation'.tr,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              Icon(Icons.attach_money, color: Colors.teal),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'sprache',
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Minimale Breite
                            children: [
                              SizedBox(
                                width: 120,
                                // Hier die gewünschte Breite festlegen
                                child: Text(
                                  'Change Language'.tr,
                                  style:const TextStyle(color: Colors.white),
                                ),
                              ),
                              Icon(Icons.language, color: Colors.teal),
                            ],
                          ),
                        ),
                      ];
                    },
                    color: const Color(0xFF646363),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start, // Ausrichtung oben
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 60, top: 16),
                      // Verschiebung nach links und oben
                      child: Text(
                        'Select Shift'.tr,
                        style:const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Radio<String>(
                      value: 'Early',
                      activeColor: const Color(0xFFFFFFFF),
                      groupValue: shiftType,
                      onChanged: _selectShift,
                    ),
                    Text('Early Shift'.tr,
                        style: const TextStyle(color: Colors.white)),
                    Radio<String>(
                      value: 'Late',
                      activeColor: const Color(0xFFFFFFFF),
                      groupValue: shiftType,
                      onChanged: _selectShift,
                    ),
                    Text('Late Shift'.tr,
                        style:const TextStyle(color: Colors.white)),
                    Radio<String>(
                      value: 'Night',
                      activeColor: const Color(0xFFFFFFFF),
                      groupValue: shiftType,
                      onChanged: _selectShift,
                    ),
                    Text('Night Shift'.tr,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),
            // Button zur Auswahl der Startzeit
            Row(
              children: [
                const SizedBox(width: 30), // Abstand
                const Icon(
                  Icons.access_time,
                  color: Color(0xFFFFFFFF),
                  size: 32,
                ),
                const SizedBox(width: 30), // Abstand
                Align(
                  alignment: const Alignment(-0.5, 0),
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.black,
                        backgroundColor: Colors.teal,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        _showCupertinoTimePicker(context, 'start');
                      },
                      child: Text(
                        "${startTimeUebertragung}",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20), // Textfarbe
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Anzeige der gewählten Startzeit

            const SizedBox(height: 32),
            // Button zur Auswahl der Endzeit
            Row(
              children: [
                const SizedBox(width: 30), // Abstand
                const Icon(
                  Icons.access_time,
                  color: Color(0xFFFFFFFF),
                  size: 32,
                ),
                const SizedBox(width: 30), // Abstand
                Align(
                  alignment: const Alignment(-0.5, 0),
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.black,
                        backgroundColor: Colors.teal,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        _showCupertinoTimePicker(context, 'end');
                      },
                      child: Text(
                        "${endTimeUebertragung}",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 20), // Textfarbe
                      ),
                    ),
                  ),
                ),
              ],
            ), // Anzeige der gewählten Endzeit

            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Anzeige der Zeitdifferenz
                Text(
                  "Dif: ${calculateTimeDifference()}",
                  style:
                  const TextStyle(fontSize: 16, color: Color(0xFFF4F5F4)),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: const Alignment(-0.5, 0),
                  child: SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.black,
                        backgroundColor: _isPressedButton1
                            ? Colors.blue
                            : Colors.teal, // Button 1 Farbe
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          handlePress(1);
                          loadBreakTimes();
                        });
                        _addEntry();
                      },
                      child:  Text(
                        'Add'.tr,
                        style:const TextStyle(
                            color: Colors.white, fontSize: 32), // Textfarbe
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Align(
                  alignment: const Alignment(-0.5, 0),
                  child: SizedBox(
                    width: 350,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.black,
                        backgroundColor: _isPressedButton2
                            ? Colors.blue
                            : Colors.teal, // Button 2 Farbe
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () {
                        handlePress(2);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListviewScreen()),
                        );
                      },
                      child:  Text(
                        'Show Entries'.tr,
                        style:const TextStyle(
                            color: Colors.white, fontSize: 32), // Textfarbe
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showPopup(BuildContext context) {
    String selectedLanguage = language; // Lokale Variable zur Auswahl der Sprache

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose language'.tr),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min, // Minimale Größe für den Dialog
                children: [
                  RadioListTile<String>(
                    title: const Text('English', style: TextStyle(color: Colors.black)),
                    value: 'English',
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Deutsch', style: TextStyle(color: Colors.black)),
                    value: 'Deutsch',
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('عربي', style: TextStyle(color: Colors.black)),
                    value: 'عربي',
                    groupValue: selectedLanguage,
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value!;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'.tr),
              onPressed: () async {
                // Sprache ändern und speichern
// Standardwert
                if (selectedLanguage == 'Deutsch') {
                  localeCode = 'de_Gr';
                } else if (selectedLanguage == 'عربي') {
                  localeCode = 'ar_AR';
                }
                // Aktualisiere die Sprache mit GetX
                updateLanguage(localeCode);
                // Dialog schließen
                Navigator.of(context).pop();

                print('Ausgewählte Sprache: $selectedLanguage');
              },
            ),
            TextButton(
              child: Text('Cancel'.tr),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  CustomAppBar({this.height = kToolbarHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Colors.teal,
      child: const Center(
        child: Text(
          '',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
