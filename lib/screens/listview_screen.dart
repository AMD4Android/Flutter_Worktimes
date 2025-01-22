import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

  // Methode zum Laden der Einträge
  Future<void> _loadEntries() async {
    final data = await DatabaseService.instance.getEntries();
    setState(() {
      groupedEntries = _groupEntriesByEmployer(data);
    });
  }

  // Gruppiere Einträge nach Arbeitgeber
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

  // Methode zum Erstellen eines PDF-Dokuments
  Future<void> _exportToPdf() async {
    final pdf = pw.Document();

    // Füge jede Gruppe von Einträgen zum PDF hinzu
    groupedEntries.forEach((employer, entries) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  employer,
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(),
                ...entries.map((entry) {
                  return pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(entry['date'] ?? ''),
                      ),
                      // hier muss noch die Schicht geschrieben werden
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(entry['shift'] ?? ''),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(entry['start'] ?? ''),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(entry['end'] ?? ''),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(entry['duration'] ?? ''),
                      ),
                    ],
                  );
                }).toList(),
              ],
            );
          },
        ),
      );
    });

    // Speichere das PDF oder zeige eine Vorschau an
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
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
            icon: const Icon(Icons.picture_as_pdf), // PDF-Icon
            onPressed: _exportToPdf, // Methode zum Exportieren aufrufen
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
                  return Card(
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
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry['start'] ?? '',
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                          ),
                          const SizedBox(width: 0),
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry['end'] ?? '',
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
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