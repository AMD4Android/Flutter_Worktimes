import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models&services/database_service.dart';


class LohnabrechnungsScreen extends StatefulWidget {
  const LohnabrechnungsScreen({super.key});

  @override
  State<LohnabrechnungsScreen> createState() => _LohnabrechnungsScreenState();
}

String dauer = "";
String gesamtLohn = "";
String spaetschichtGesamt = "";
String nightschichtGesamt = "";
double bonusLate = 0;
double bonusNight = 0;
String bonusLateString = "";
String bonusnightString = "";
double LohnstundenINDouble = 0;
bool _isInputDisabled = false;
bool _isInputDisabled2 = false;

class _LohnabrechnungsScreenState extends State<LohnabrechnungsScreen> {
  TextEditingController hourlyWageController = TextEditingController();
  TextEditingController lateShiftBonusController = TextEditingController();
  TextEditingController nightShiftBonusController = TextEditingController();
  TextEditingController lateShiftStartController = TextEditingController();
  TextEditingController nightShiftStartController = TextEditingController();
  String selectedMonth = 'Select Month'.tr;
  int selectedYear = DateTime.now().year;

  bool isHourlyWageEmpty = false;
  bool isLateShiftBonusEmpty = false;
  bool isNightShiftBonusEmpty = false;
  bool isLateShiftStartEmpty = false;
  bool isNightShiftStartEmpty = false;
  bool isMonthlyFlatRateEmpty = false;
  int month = 0;
  int year = 0;

  @override
  void dispose() {
    hourlyWageController.dispose();
    lateShiftBonusController.dispose();
    nightShiftBonusController.dispose();
    lateShiftStartController.dispose();
    nightShiftStartController.dispose();

    super.dispose();
  }

  void _showMonthYearPicker(BuildContext context) {
    int year = DateTime.now().year;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            month = index + 1;
                            selectedMonth = _getMonthName(month);
                          });
                        },
                        children: List<Widget>.generate(12, (int index) {
                          return Center(
                            child: Text(
                              _getMonthName(index + 1),
                              style:
                              TextStyle(fontSize: 24, color: Colors.blue),
                            ),
                          );
                        }),
                      ),
                    ),
                    Expanded(
                      child: CupertinoPicker(
                        itemExtent: 32.0,
                        onSelectedItemChanged: (int index) {
                          setState(() {
                            year = DateTime.now().year + index;
                            selectedYear = year;
                          });
                        },
                        children: List<Widget>.generate(10, (int index) {
                          return Center(
                            child: Text(
                              '${DateTime.now().year + index}',
                              style:
                              TextStyle(fontSize: 24, color: Colors.blue),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                child:  Text('Done'.tr,
                  style:  TextStyle(fontSize: 24, color: Colors.blue),),
                onPressed: () {
                  Navigator.pop(context);
                  print(
                      'Ausgewählter Monat und Jahr: $selectedMonth $selectedYear');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String m1 = 'January'.tr;
  String m2 = 'February'.tr;
  String m3 = 'March'.tr;
  String m4 = 'April'.tr;
  String m5 = 'May'.tr;
  String m6 = 'June'.tr;
  String m7 = 'July'.tr;
  String m8 = 'August'.tr;
  String m9 = 'September'.tr;
  String m10 = 'October'.tr;
  String m11 = 'November'.tr;
  String m12 = 'December'.tr;

  String _getMonthName(int month) {
    final monthNames = [
      m1,m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12
    ];
    return monthNames[month - 1];
  }

  void _validateInputs() {
    setState(() {
      isHourlyWageEmpty = hourlyWageController.text.isEmpty;
      //isLateShiftBonusEmpty = lateShiftBonusController.text.isEmpty;
      //isNightShiftBonusEmpty = nightShiftBonusController.text.isEmpty;
      //isLateShiftStartEmpty = lateShiftStartController.text.isEmpty;
      //isNightShiftStartEmpty = nightShiftStartController.text.isEmpty;
      //isMonthlyFlatRateEmpty = monthlyFlatRateController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Wage Calculation'.tr,
          style: TextStyle(fontSize: 28, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFF4F5F4),
          size: 30,
        ),
        backgroundColor:  Colors.teal,toolbarHeight: 80,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 25),
            Text(
              'Hourly wage'.tr,
              style: TextStyle(fontSize: 18, color: Color(0xFFF4F5F4)),
            ),
            SizedBox(
              child: TextField(
                controller: hourlyWageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 15.00',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isHourlyWageEmpty ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isHourlyWageEmpty ? Colors.red : Colors.teal,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Late shift bonus in %'.tr,
              style: TextStyle(fontSize: 18, color: Color(0xFFF4F5F4)),
            ),
            SizedBox(
              child: TextField(
                controller: lateShiftBonusController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 1.50',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:Colors.teal,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Night shift bonus in %'.tr,
              style: TextStyle(fontSize: 18, color: Color(0xFFF4F5F4)),
            ),
            SizedBox(
              child: TextField(
                controller: nightShiftBonusController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 2.00',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:Colors.teal,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Late shift starts at (hour)'.tr,
              style: TextStyle(fontSize: 18, color: Color(0xFFF4F5F4)),
            ),
            SizedBox(
              child: TextField(
                controller: lateShiftStartController,
                maxLength: 5,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 18:30 (6:30 PM)',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:Colors.teal,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (text) {
                  _formatInputLate(text);
                },
                //enabled: !_isInputDisabled,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Night shift starts at (hour)'.tr,
              style: TextStyle(fontSize: 18, color: Color(0xFFF4F5F4)),
            ),
            SizedBox(
              child: TextField(
                controller: nightShiftStartController,
                maxLength: 5,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 18:30 (6:30 PM)',
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:Colors.teal,
                    ),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (text) {
                  _formatInputNight(text);
                },
                //enabled: !_isInputDisabled2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Wage for:'.tr,
              style: TextStyle(fontSize: 18, color: Color(0xFFF4F5F4)),
            ),
            const SizedBox(height: 1),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: const Alignment(0, 0),
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.black,
                        backgroundColor:  Colors.teal,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: () => _showMonthYearPicker(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.date_range,color: Colors.white,),
                          const SizedBox(width: 8),
                          Text(
                            "$selectedMonth $selectedYear",
                            style:
                            TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors
                                  .white), // Setze die Farbe der Umrandung auf weiß
                        ),
                        child: Text(
                          'Duration:'.tr + '$dauer',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 2,
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors
                                  .white), // Setze die Farbe der Umrandung auf weiß
                        ),
                        child: Text(
                          '${gesamtLohn}\$',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 2,
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Align(
                alignment: const Alignment(0, 0),
                child: SizedBox(
                  width: 285,
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
                      fetchEntriesForNovember(month, selectedYear);
                      setState(() {
                        _validateInputs();

                      });
                      //fetchEntries();
                      if (hourlyWageController.text == "") {
                        ScaffoldMessenger.of(context)
                            .showSnackBar( SnackBar(
                          content: Text('Hourly wage is 0'.tr),
                        ));
                      }
                    },
                    child:  Text(
                      'Calculate'.tr,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _formatInputNight(String text) {
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
    nightShiftStartController.value = nightShiftStartController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  void _formatInputLate(String text) {
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
    lateShiftStartController.value = lateShiftStartController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  void fetchEntries() async {
    List<Map<String, dynamic>> entries =
    await DatabaseService.instance.getEntries();
    for (var entry in entries) {
      print(
          'Eintrag: ${entry['employer']} - ${entry['date']} von ${entry['start']} bis ${entry['end']}');
    }
  }

  void fetchEntriesForNovember(int month, int selectedYear) async {
    List<Map<String, dynamic>> entries =
    await DatabaseService.instance.getEntries();

    List<String> durationList = [];
    List<String> spaetschichtList = [];
    List<String> nightschichtList = [];
    List<String> zulagenlateListe = [];
    List<String> zulagennightListe = [];

    String lateZeit = "";
    String nightZeit = "";
    // Nur die Einträge für November filtern
    List<Map<String, dynamic>> novemberEntries = entries.where((entry) {
      String date = entry['date'];
      return date.contains(
          '.$month.$selectedYear'); // Prüft, ob das Datum den Monat 11 enthält
    }).toList();

    for (var entry in novemberEntries) {
      print(
          'Eintrag: ${entry['employer']} - ${entry['date']} von ${entry['start']} bis ${entry['end']} shift ${entry['shift']}');
      String Duration = "${entry['duration']}";
      durationList.add(Duration);

      lateZeit = entry['shift'];
      if (lateShiftBonusController.text.isNotEmpty && lateZeit == "Late") {
        String Spaetzeitendauer = "${entry['duration']}";
        spaetschichtList.add(Spaetzeitendauer);
        spaetschichtGesamt = rechneDuration(spaetschichtList);
      }
      nightZeit = entry['shift'];
      if (nightShiftBonusController.text.isNotEmpty && nightZeit == "Night") {
        String Nightzeitendauer = "${entry['duration']}";
        nightschichtList.add(Nightzeitendauer);
        nightschichtGesamt = rechneDuration(nightschichtList);
      }
    }

    bool night = false;
    zulagenlateListe = rechneDifferenzforZulagen(novemberEntries, night);
    // zulagenlateListe zusammenrechnen und mit multiplikator rechnen
    bonusLateString = rechneDuration(zulagenlateListe);
    night = true;
    zulagennightListe = rechneDifferenzforZulagen(novemberEntries, night);
    bonusnightString = rechneDuration(zulagennightListe);
    setState(() {
      dauer = rechneDuration(durationList);
      CountFundamentalWage(dauer, hourlyWageController);
    });
  }

  List<String> rechneDifferenzforZulagen(
      List<Map<String, dynamic>> novemberEntries, bool night) {
    String spaetschichtzulagenzeitBerechnet = "";
    List<String> zulagenListe = []; // Liste zur Speicherung der Zulagen
    String vergleichszeit = "";
    if (night == false) {
      vergleichszeit = lateShiftStartController.text;
    } else {
      vergleichszeit = nightShiftStartController.text;
    }

    for (var entry in novemberEntries) {
      String endzeit = entry['end']; // Endzeit aus dem Eintrag

      if (endzeit.compareTo(vergleichszeit) > 0) {
        // Berechnung der Differenz
        if(vergleichszeit == ""){
          String formattedDifferenz = "00h:00m";
          zulagenListe.add(formattedDifferenz);
        }
        else{

          DateTime endDateTime =
          DateTime.parse("2023-01-01 $endzeit"); // Beispiel-Datum
          DateTime vergleichsDateTime =
          DateTime.parse("2023-01-01 $vergleichszeit");

          Duration differenz = endDateTime.difference(vergleichsDateTime);

          // Formatieren der Differenz in "xxh:yym" mit führenden Nullen
          String formattedDifferenz =
              "${differenz.inHours.toString().padLeft(2, '0')}h:${(differenz.inMinutes % 60).toString().padLeft(2, '0')}m";

          zulagenListe.add(formattedDifferenz); // Füge zur Liste hinzu
        }
      }
    }
    return zulagenListe;
  }

  String rechneDuration(List<String> durationList) {
    // Gesamtstunden und Gesamtminuten initialisieren
    // Gesamtstunden und Gesamtminuten initialisieren
    int totalHours = 0;
    int totalMinutes = 0;
    String x = "00:00";
    String result = "";
    if (durationList.length >= 1) {
      // Durchlaufe die Liste und addiere die Zeiten
      for (String duration in durationList) {
        // Teile den String in Stunden und Minuten
        String _hours = duration.substring(0, 2);
        String _minutes = duration.substring(4, 6);

        int hours = int.parse(_hours);
        int minutes = int.parse(_minutes);

        // Addiere zu den Gesamtstunden und Gesamtminuten
        totalHours += hours;
        totalMinutes += minutes;
      }

      // Umwandlung von Minuten in Stunden
      totalHours += totalMinutes ~/ 60; // Ganze Stunden aus Minuten
      totalMinutes = totalMinutes % 60;
      result =
      '${totalHours.toString().padLeft(2, '0')}h:${totalMinutes.toString().padLeft(2, '0')}m';
      print('Gesamtdauer: $result');

      return result;
    } else {
      return x;
    }
    // Verbleibende Minuten

    // Ergebnis im Format xxh:yym ausgeben

    setState(() {
      dauer = result;
    });
  }

  void CountFundamentalWage(
      String dauer, TextEditingController hourlyWageController) async {
    RegExp regExp = RegExp(r'(\d+)h:(\d+)m');
    Match? match = regExp.firstMatch(dauer);

    if (match != null) {
      // Stunden und Minuten extrahieren
      int stunden = int.parse(match.group(1)!);
      int minuten = int.parse(match.group(2)!);

      String _LohnstundenUmwandlung = hourlyWageController.text.toString();

      String LohnstundenUmwandlung =
      _LohnstundenUmwandlung.replaceAll(',', '.');

      if (LohnstundenUmwandlung.isNotEmpty) {
        if (lateShiftBonusController.text.isEmpty &&
            nightShiftBonusController.text.isEmpty) {
          LohnstundenINDouble = double.parse(LohnstundenUmwandlung);
        } else {
          LohnstundenINDouble = double.parse(LohnstundenUmwandlung);
          CountBonusesAndFundamentalWage(
              lateShiftBonusController.text.toString(),
              nightShiftBonusController.text.toString(),
              double.parse(LohnstundenUmwandlung));
        }
      }
      // Umrechnung der Minuten in Stunden
      double minutenInStunden = minuten / 60.0;
      // Gesamtstunden berechnen
      double gesamtstunden = stunden + minutenInStunden;

      // Gesamtgehalt berechnen
      double gesamtGehalt =
          gesamtstunden * LohnstundenINDouble + bonusLate + bonusNight;
      setState(() {
        gesamtLohn = gesamtGehalt.toStringAsFixed(2);
      });
    } else {
      gesamtLohn = 0.toString();
    }
  }

  void CountBonusesAndFundamentalWage(
      String lateBonus, String nightBonus, double LohnstundenINDouble) {
    if (lateBonus != "") {
      if (!(lateBonus is double)) {
        lateBonus = lateBonus.replaceAll(',', '.');
      }
      double lateBonusInDouble =
          double.parse(lateBonus) * LohnstundenINDouble / 100;
      bonusLate = multiplyDuration(bonusLateString,
          lateBonusInDouble); // "lateduraton" * prozentforLate;
    } else {
      double lateBonusInDouble = 0;
      bonusLate = multiplyDuration(bonusLateString, lateBonusInDouble);
    }
    if (nightBonus != "") {
      if (!(nightBonus is double)) {
        nightBonus = nightBonus.replaceAll(',', '.');
      }
      double nightBonusInDouble =
          double.parse(nightBonus) * LohnstundenINDouble / 100;
      bonusNight = multiplyDuration(bonusnightString, nightBonusInDouble);
    } else {
      double nightBonusInDouble = 0;
      bonusNight = multiplyDuration(bonusnightString, nightBonusInDouble);
    }
  }

  // Rechnet gesamte Dauer mit den Multiplikationsfaktoren
  double multiplyDuration(String duration, double multiplier) {
    if (duration == "" || duration == "00:00") {
      duration = "00h:00m";
    }
    // Extrahiere Stunden und Minuten aus dem `duration` String
    final hours = int.parse(duration.substring(0, 2));
    final minutes = int.parse(duration.substring(4, 6));

    // Konvertiere die Gesamtdauer in Minuten
    int totalMinutes = (hours * 60) + minutes;

    // Konvertiere die Gesamtdauer in Dezimalstunden
    double totalHours = hours + (minutes / 60);

    // Multipliziere die Dezimalstunden mit dem Stundenlohn
    double wage = totalHours * multiplier;

    return wage;
  }
}
