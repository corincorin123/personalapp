import 'package:flutter/material.dart';
import 'package:personal_application/Diary/diaryScreen.dart';
import 'package:personal_application/Diary/noteTaking.dart';

import 'package:personal_application/authPage/LoginPage.dart';
import 'package:personal_application/authPage/RegisterPage.dart';
import 'package:personal_application/bottomNavigationBar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      initialRoute: Loginpage.id,
      routes: {
        Loginpage.id: (context) => Loginpage(),
        Registerpage.id: (context) => Registerpage(),
        Diaryscreen.id: (context) => Diaryscreen(),
        BottomNav.id: (context) => BottomNav(),
        Notetaking.id: (context) => Notetaking(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class NoteStorage {
  static List<Map<String, String>> _notes = [];

  static List<Map<String, String>> get notes => List.unmodifiable(_notes);

  static void addNote({
    required String title,
    required String name,
    required String date,
    String content = '',
  }) {
    _notes.add({
      'title': title,
      'name': name,
      'date': date,
      'content': content,
    });
    print('Note added: $title'); // Debug print
    print('Total notes: ${_notes.length}'); // Debug print
  }

  static void removeNote(int index) {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index);
    }
  }

  static void clearAll() {
    _notes.clear();
  }
}
