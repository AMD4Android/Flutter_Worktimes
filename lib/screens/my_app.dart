import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worktimes_new/screens/zeiteintragung_screen.dart';
import 'home_screen.dart';
import 'listview_screen.dart';
import 'localString.dart';
import 'package:get/get.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Locale>(
      future: _loadLocale(), // Lade die Sprache zuerst
      builder: (BuildContext context, AsyncSnapshot<Locale> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return GetMaterialApp(
            translations: LocalString(),
            locale: snapshot.data ?? const Locale('en', 'US'), // Standard-Sprache
            title: 'Flutter Demo',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              scaffoldBackgroundColor: const Color(0xFF292929),
              inputDecorationTheme: const InputDecorationTheme(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white10, width: 2.0),
                ),
                labelStyle: TextStyle(color: Colors.white),
              ),
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.blue,
              ),
            ),
            home: FutureBuilder<Widget>(
              future: loadInitialScreen(),
              builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return snapshot.data!;
                }
              },
            ),
          );
        }
      },
    );
  }

  // Methode, um die gespeicherte Sprache zu laden
  Future<Locale> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLocale = prefs.getString('language');
    if (savedLocale != null) {
      var localeParts = savedLocale.split('_');
      return Locale(localeParts[0], localeParts[1]);
    }
    return const Locale('en', 'US'); // Standard-Sprache
  }

  // Methode, um den Startbildschirm basierend auf den gespeicherten Werten zu laden
  Future<Widget> loadInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    String newCoName = prefs.getString('saved_employer2') ?? '';
    String altCoName = prefs.getString('saved_employer') ?? '';

    if (newCoName.isNotEmpty || altCoName.isNotEmpty) {
      return Zeiteintrag_Screen();

    } else {
      return HomeScreen(title: 'Your working times'.tr);
    }
  }
}
