import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models&services/database_service.dart';

class ListviewScreen extends StatefulWidget {
  @override
  _ListviewScreenState createState() => _ListviewScreenState();
}

class _ListviewScreenState extends State<ListviewScreen> {
  Map<String, List<Map<String, dynamic>>> groupedEntries = {};
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _editEntry(Map<String, dynamic> entry) {
    // Show a dialog for editing entry details
    String EditEntry_String = 'Edit entry:'.tr;

    showDialog(
      context: context,
      builder: (context) {
        TextEditingController dateController =
        TextEditingController(text: entry['date']);
        startController = TextEditingController(text: entry['start']);
        endController = TextEditingController(text: entry['end']);
        TextEditingController durationController =
        TextEditingController(text: entry['duration']);
        TextEditingController shiftController =
        TextEditingController(text: entry['shift']);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // Eckenradius
            side: const BorderSide(
                color: Colors.teal, width: 1), // Rahmenfarbe und Dicke
          ),
          backgroundColor: const Color(0xFF292929),
          title: Text(
            EditEntry_String,
            style: const TextStyle(color: Colors.teal),
          ),
          content: SizedBox(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(
                        labelText: 'Date:'.tr,
                        labelStyle: const TextStyle(color: Colors.white60)),
                    style: const TextStyle(color: Colors.teal),
                    enabled: false,
                  ),
                  TextField(
                    controller: startController,
                    decoration: InputDecoration(
                        labelText: 'Start:'.tr,
                        labelStyle: const TextStyle(color: Colors.white60)),
                    style: const TextStyle(color: Colors.teal),
                    maxLength: 5,
                    onChanged: (text) {
                      _formatInputstart(text);
                    },
                  ),
                  TextField(
                    controller: endController,
                    decoration: InputDecoration(
                        labelText: 'End:'.tr,
                        labelStyle: const TextStyle(color: Colors.white60)),
                    style: const TextStyle(color: Colors.teal),
                    maxLength: 5,
                    onChanged: (text) {
                      _formatInputend(text);
                    },
                  ),
                  TextField(
                    controller: durationController,
                    decoration: InputDecoration(
                        labelText: 'Duration:'.tr,
                        labelStyle: const TextStyle(color: Colors.white60)),
                    style: const TextStyle(color: Colors.teal),
                    enabled: false,
                  ),
                  TextField(
                    controller: shiftController,
                    decoration: InputDecoration(
                        labelText: 'Shift:'.tr,
                        labelStyle: const TextStyle(color: Colors.white60)),
                    style: const TextStyle(color: Colors.teal),
                    enabled: false,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String duration = await _calculateDuration(
                  startController.text,
                  endController.text,
                  shiftController.text,
                );
                Map<String, dynamic> updatedEntry = {
                  'id': entry['id'],
                  'date': dateController.text,
                  'start': startController.text,
                  'end': endController.text,
                  'duration': duration,
                  'shift': shiftController.text,
                };
                await DatabaseService.instance.updateEntry(updatedEntry);
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
                _loadEntries(); // Refresh the UI
              },
              child: Text(
                'Save'.tr,
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel'.tr,
                style: const TextStyle(color: Colors.white60),
              ),
            ),
          ],
        );
      },
    );
  }

  void _formatInputstart(String text) {
    // Entferne alle nicht-numerischen Zeichen
    String newText = text.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      if (newText.length >= 2) {
        if (newText.length == 2) {
          newText = '${newText.substring(0, 2)}';
        }
        newText = '${newText.substring(0, 2)}:${newText.substring(2)}';
      }
    });
    // Setze den Text im Controller zurück
    startController.value = startController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  void _formatInputend(String text) {
    // Entferne alle nicht-numerischen Zeichen
    String newText = text.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      if (newText.length >= 2) {
        if (newText.length == 2) {
          newText = '${newText.substring(0, 2)}';
        }
        newText = '${newText.substring(0, 2)}:${newText.substring(2)}';
      }
    });
    // Setze den Text im Controller zurück
    endController.value = endController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  Future<String> _calculateDuration(
      String start, String end, String shift) async {
    List<String> startParts = start.split(':');
    List<String> endParts = end.split(':');
    int startHours = int.parse(startParts[0]);
    int startMinutes = int.parse(startParts[1]);
    int endHours = int.parse(endParts[0]);
    int endMinutes = int.parse(endParts[1]);
    if (startHours < 24 && startMinutes < 60 && endHours < 24 && endMinutes < 60) {
      int pauseMinutes = await _loadBreakTimes(shift);
      DateTime startDateTime = DateTime(0, 1, 1, startHours, startMinutes);
      DateTime endDateTime = DateTime(0, 1, 1, endHours, endMinutes);
      DateTime zwischenendDateTimefuerNachtschicht = DateTime(0, 1, 1, 24, 0);
      DateTime zwischenendDateTimefuerNachtschicht2 = DateTime(0, 1, 1, 0, 0);

      int zwischenDifferenceStunden = 0;
      int zwischenDifferenceMinuten = 0;
      Duration difference = Duration.zero;

      if (endHours < startHours) {
        zwischenDifferenceStunden = endHours;
        zwischenDifferenceMinuten = endMinutes;
        Duration difference1fuerNachtschicht =
        zwischenendDateTimefuerNachtschicht.difference(startDateTime);
        Duration difference2fuerNachtschicht =
        endDateTime.difference(zwischenendDateTimefuerNachtschicht2);
        difference = difference1fuerNachtschicht + difference2fuerNachtschicht;
      } else {
        difference = endDateTime.difference(startDateTime);
      }
      print("pauseMinutes: $pauseMinutes");
      Duration adjustedDifference;
      if (difference > Duration(hours: 6)) {
        adjustedDifference = difference - Duration(minutes: pauseMinutes);
      } else {
        adjustedDifference = difference;
      }
      int hours = adjustedDifference.inHours;
      int minutes = adjustedDifference.inMinutes.remainder(60);

      return "${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m";
    }
    return "00h 00m";
  }

  Future<int> _loadBreakTimes(String shift) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int earlyShiftBreak = prefs.getInt('earlyShiftBreak') ?? 0;
    int lateShiftBreak = prefs.getInt('lateShiftBreak') ?? 0;
    int nightShiftBreak = prefs.getInt('nightShiftBreak') ?? 0;

    print("Schicht: $shift"); // Debugging, um den Schichtwert zu überprüfen

    if (shift == 'Early') {
      return earlyShiftBreak;
    } else if (shift == 'Late') {
      return lateShiftBreak;
    } else if (shift == 'Night') {
      return nightShiftBreak;
    }

    return 0;
  }

  Future<void> _loadEntries() async {
    final data = await DatabaseService.instance.getEntries();
    setState(() {
      groupedEntries = _groupEntriesByEmployer(data);
    });
  }

  Map<String, List<Map<String, dynamic>>> _groupEntriesByEmployer(
      List<Map<String, dynamic>> entries) {
    Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var entry in entries) {
      String employer = entry['employer'] ?? "Unknown Employer";
      if (!grouped.containsKey(employer)) {
        grouped[employer] = [];
      }
      grouped[employer]!.add(entry);
    }
    return grouped;
  }

  Future<bool?> _confirmDelete(BuildContext context, entry) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5), // Eckenradius
            side: const BorderSide(
                color: Colors.red, width: 1), // Rahmenfarbe und Dicke
          ),
          backgroundColor: const Color(0xFF292929),
          title: Text(
            'Confirm deletion'.tr,
            style: const TextStyle(color: Colors.white60),
          ),
          content: Text(
            'Do you really want to delete this entry?'.tr,
            style: const TextStyle(color: Colors.white60),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel'.tr,
                style: const TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await DatabaseService.instance.deleteEntry(entry);
              },
              child: Text(
                'Delete'.tr,
                style: const TextStyle(color: Colors.white60),
              ),
            ),
          ],
        );
      },
    );
  }

  // Methode zum Exportieren der ListView-Einträge
  void _exportEntries() {
    // Hier kannst du die Logik zum Exportieren der Einträge implementieren
    // Zum Beispiel: Speichern in einer Datei, Teilen über eine App usw.
    print("Exporting entries...");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time Entries'.tr),
        backgroundColor: Colors.teal,
        foregroundColor: const Color(0xFFFFFFFF),
        titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
        iconTheme: const IconThemeData(
          color: Color(0xFFF4F5F4),
          size: 30,
        ),
        // Icon rechts in der AppBar für den Export
        actions: [
          IconButton(
            icon: const Icon(Icons.upload), // Icon für den Export
            onPressed: _exportEntries, // Methode zum Exportieren aufrufen
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: groupedEntries.keys.length,
          itemBuilder: (context, index) {
            String employerName = groupedEntries.keys.elementAt(index);
            List<Map<String, dynamic>> employerEntries =
                groupedEntries[employerName] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employerName,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                const Divider(color: Colors.white),
                ...employerEntries.map((entry) {
                  return Dismissible(
                    key: Key(entry['id'].toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blue,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        return await _confirmDelete(context, entry['id']);
                      } else if (direction == DismissDirection.endToStart) {
                        _editEntry(entry);
                        return false;
                      }
                      return false;
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: const Color(0xFF292929),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                entry['date'] ?? '',
                                softWrap: false,
                                style:
                                const TextStyle(color: Color(0xFFFFFFFF)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry['start'] ?? '',
                                style:
                                const TextStyle(color: Color(0xFFFFFFFF)),
                              ),
                            ),
                            const SizedBox(width: 0),
                            Expanded(
                              flex: 2,
                              child: Text(
                                entry['end'] ?? '',
                                style:
                                const TextStyle(color: Color(0xFFFFFFFF)),
                              ),
                            ),
                            const SizedBox(width: 0),
                            Container(
                              width: 100,
                              padding: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  entry['duration'] ?? '',
                                  style: const TextStyle(
                                      color: Color(0xFFFFFFFF), fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}