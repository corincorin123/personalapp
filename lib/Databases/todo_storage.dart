import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoItem {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final int listNumber;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    required this.listNumber,
  });

  TodoItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    int? listNumber,
  }) => TodoItem(
    id: id ?? this.id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    listNumber: listNumber ?? this.listNumber,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'listNumber': listNumber,
  };

  factory TodoItem.fromMap(Map<String, dynamic> data) {
    final rawCreated = data['createdAt'];
    DateTime created;
    if (rawCreated is Timestamp) {
      created = rawCreated.toDate();
    } else if (rawCreated is String) {
      created = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }
    return TodoItem(
      id: data['id'] as String,
      title: data['title'] as String? ?? '',
      isCompleted: (data['isCompleted'] as bool?) ?? false,
      createdAt: created,
      listNumber: (data['listNumber'] as num?)?.toInt() ?? 0,
    );
  }
}

class TodoList {
  final String name;
  final String date;
  final List<TodoItem> items;
  final DateTime createdAt;

  TodoList({
    required this.name,
    required this.date,
    required this.items,
    required this.createdAt,
  });

  TodoList copyWith({
    String? name,
    String? date,
    List<TodoItem>? items,
    DateTime? createdAt,
  }) => TodoList(
    name: name ?? this.name,
    date: date ?? this.date,
    items: items ?? this.items,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toFirestore({bool update = false}) => {
    'name': name,
    'date': date,
    'items': items.map((item) => item.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'timestamp': FieldValue.serverTimestamp(),
  };

  factory TodoList.fromFirestore(Map<String, dynamic> data) {
    final rawCreated = data['createdAt'];
    DateTime created;
    if (rawCreated is Timestamp) {
      created = rawCreated.toDate();
    } else if (rawCreated is String) {
      created = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    final itemsRaw = (data['items'] as List?) ?? const [];
    final items = itemsRaw
        .whereType<Map<String, dynamic>>()
        .map((e) => TodoItem.fromMap(e))
        .toList();

    return TodoList(
      name: data['name'] as String? ?? '',
      date: data['date'] as String? ?? '',
      items: items,
      createdAt: created,
    );
  }
}

class TodoStorage {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<TodoList> _todoLists = <TodoList>[];
  static final List<String> _docIds = <String>[];

  static List<TodoList> get todoLists => List.unmodifiable(_todoLists);

  static CollectionReference<Map<String, dynamic>> _userTodoCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please log in first');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('todo_lists');
  }

  static Future<void> loadTodoLists() async {
    try {
      final query = await _userTodoCollection()
          .orderBy('timestamp', descending: true)
          .get();

      _todoLists
        ..clear()
        ..addAll(query.docs.map((d) => TodoList.fromFirestore(d.data())));
      _docIds
        ..clear()
        ..addAll(query.docs.map((d) => d.id));
    } catch (_) {
      _todoLists.clear();
      _docIds.clear();
    }
  }

  static Future<void> addTodoList(TodoList todoList) async {
    try {
      await _userTodoCollection().add(todoList.toFirestore());
      await loadTodoLists();
    } on FirebaseException catch (e) {
      throw Exception('Failed to add todo list: ${e.message}');
    } catch (e) {
      throw Exception(
        'Connection error. Please check your internet connection and try again.',
      );
    }
  }

  static Future<void> updateTodoList(int index, TodoList todoList) async {
    if (index < 0 || index >= _docIds.length) return;
    final docId = _docIds[index];
    try {
      await _userTodoCollection().doc(docId).update(todoList.toFirestore());
      await loadTodoLists();
    } on FirebaseException catch (e) {
      throw Exception('Failed to update todo list: ${e.message}');
    } catch (e) {
      throw Exception(
        'Connection error. Please check your internet connection and try again.',
      );
    }
  }

  static Future<void> removeTodoList(int index) async {
    if (index < 0 || index >= _docIds.length) return;
    final docId = _docIds[index];
    try {
      await _userTodoCollection().doc(docId).delete();
      _todoLists.removeAt(index);
      _docIds.removeAt(index);
    } catch (_) {}
  }

  static Future<void> toggleTodoItem(int listIndex, String itemId) async {
    if (listIndex < 0 || listIndex >= _todoLists.length) return;
    final todoList = _todoLists[listIndex];
    final updatedItems = todoList.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();

    final updatedList = todoList.copyWith(items: updatedItems);
    _todoLists[listIndex] = updatedList;

    if (listIndex < 0 || listIndex >= _docIds.length) return;
    final docId = _docIds[listIndex];
    try {
      await _userTodoCollection().doc(docId).update({
        'items': updatedItems.map((e) => e.toMap()).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  static Future<void> clearAll() async {
    try {
      final col = _userTodoCollection();
      final batch = _firestore.batch();
      final docs = await col.get();
      for (final d in docs.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
      _todoLists.clear();
      _docIds.clear();
    } catch (_) {}
  }

  static List<TodoItem> getDefaultSelfCareItems() {
    return <TodoItem>[];
  }

  static String getListCategoryName(int listNumber) {
    switch (listNumber) {
      case 1:
        return 'Health Goals';
      case 2:
        return 'Wellness Tasks';
      case 3:
        return 'Life Organization';
      case 4:
        return 'Personal Growth';
      default:
        return 'Tasks';
    }
  }

  static String getListTitle(int listNumber) {
    return 'TO-DO LIST $listNumber';
  }
}
