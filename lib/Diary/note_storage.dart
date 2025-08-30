// Create this as a separate file: note_storage.dart
// Or add this class at the top of your main.dart file

class NoteStorage {
  static List<Map<String, String>> _notes = [];

  static List<Map<String, String>> get notes => _notes;

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
