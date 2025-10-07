import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Note {
  final String? id;
  final String title;
  final String name;
  final String date;
  final String content;

  Note({
    this.id,
    required this.title,
    required this.name,
    required this.date,
    this.content = '',
  });

  factory Note.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      name: data['name'] ?? 'Anonymous',
      date: data['date'] ?? '',
      content: data['content'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'name': name,
      'date': date,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}

class DiaryService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addNote(Note note) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("Please log in first");
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('diary_notes')
          .add(note.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Failed to add note: ${e.message}');
    } catch (e) {
      throw Exception(
        'Connection error. Please check your internet connection and try again.',
      );
    }
  }

  Stream<QuerySnapshot> getNotesStream() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("Please log in first");
      }

      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('diary_notes')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      throw Exception(
        'Failed to connect to database. Please check your internet connection.',
      );
    }
  }

  Future<void> updateNote(String docId, Note note) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("Please log in first");
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('diary_notes')
          .doc(docId)
          .update(note.toFirestore());
    } on FirebaseException catch (e) {
      throw Exception('Failed to update note: ${e.message}');
    } catch (e) {
      throw Exception(
        'Connection error. Please check your internet connection and try again.',
      );
    }
  }

  Future<void> deleteNote(String docId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("Please log in first");
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('diary_notes')
          .doc(docId)
          .delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete note: ${e.message}');
    } catch (e) {
      throw Exception(
        'Connection error. Please check your internet connection and try again.',
      );
    }
  }

  Future<bool> checkConnection() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('diary_notes')
          .limit(1)
          .get();
      return true;
    } catch (e) {
      return false;
    }
  }
}
