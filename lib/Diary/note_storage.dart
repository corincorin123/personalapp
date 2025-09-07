import 'dart:async';

class Note {
  final String title;
  final String name;
  final String date;
  final String content;

  Note({
    required this.title,
    required this.name,
    required this.date,
    this.content = '',
  });

  Note copyWith({String? title, String? name, String? date, String? content}) =>
      Note(
        title: title ?? this.title,
        name: name ?? this.name,
        date: date ?? this.date,
        content: content ?? this.content,
      );
}

class NoteStorage {
  static final List<Note> _notes = <Note>[];

  static List<Note> get notes => List.unmodifiable(_notes);

  static Future<void> loadNotes() async {
    return;
  }

  static Future<void> addNote(Note note) async {
    await Future.delayed(const Duration(seconds: 2));
    _notes.add(note);
  }

  static Future<void> updateNote(int index, Note note) async {
    await Future.delayed(const Duration(seconds: 2));
    if (index >= 0 && index < _notes.length) {
      _notes[index] = note;
    }
  }

  static Future<void> removeNote(int index) async {
    if (index >= 0 && index < _notes.length) {
      _notes.removeAt(index);
    }
  }

  static Future<void> clearAll() async {
    _notes.clear();
  }
}
