import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';

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

  Map<String, dynamic> toRealtimeMap() => {
    'name': name,
    'date': date,
    'items': items.map((item) => item.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'timestamp': ServerValue.timestamp,
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
        .map((e) => e is Map ? TodoItem.fromMap(Map<String, dynamic>.from(e as Map)) : null)
        .whereType<TodoItem>()
        .toList();

    return TodoList(
      name: data['name'] as String? ?? '',
      date: data['date'] as String? ?? '',
      items: items,
      createdAt: created,
    );
  }

  factory TodoList.fromRealtime(Map<String, dynamic> data) {
    final rawCreated = data['createdAt'];
    DateTime created;
    if (rawCreated is String) {
      created = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      created = DateTime.now();
    }

    final itemsRaw = (data['items'] as List?) ?? const [];
    final items = itemsRaw
        .map((e) => e is Map ? TodoItem.fromMap(Map<String, dynamic>.from(e as Map)) : null)
        .whereType<TodoItem>()
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
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  static const String _databaseUrl = 'https://personalapp-b6dee-default-rtdb.firebaseio.com';
  static FirebaseDatabase get _rtdb => FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: _databaseUrl);

  static final List<TodoList> _todoLists = <TodoList>[];
  static final List<String> _docIds = <String>[];
  static final ValueNotifier<List<TodoList>> todoListsNotifier =
      ValueNotifier<List<TodoList>>(<TodoList>[]);
  static ValueListenable<List<TodoList>> get todoListsListenable => todoListsNotifier;
  static StreamSubscription<dynamic>? _subscription;
  static TodoBackend? _backendOverride;

  static List<TodoList> get todoLists => List.unmodifiable(_todoLists);

  static String? docIdForIndex(int index) {
    if (index < 0 || index >= _docIds.length) return null;
    return _docIds[index];
  }

  static TodoList? listForDocId(String docId) {
    final idx = _docIds.indexOf(docId);
    if (idx == -1) return null;
    return _todoLists[idx];
  }

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

  static DatabaseReference _userTodoRef() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Please log in first');
    }
    return _rtdb.ref('users/${user.uid}/todo_lists');
  }

  static Future<void> loadTodoLists() async {
    try {
      Map<String, TodoList> listsById;
      if (_backendOverride != null) {
        listsById = await _backendOverride!.load();
      } else {
        final snap = await _userTodoRef().get();
        listsById = <String, TodoList>{};
        for (final child in snap.children) {
          final key = child.key;
          final value = child.value;
          if (key != null && value is Map<dynamic, dynamic>) {
            final data = Map<String, dynamic>.from(value);
            listsById[key] = TodoList.fromRealtime(data);
          }
        }

        if (listsById.isEmpty) {
          final fallback = await _loadFromFirestore();
          if (fallback.isNotEmpty) {
            await _migrateFromFirestoreToRealtime(fallback);
            listsById.addAll(fallback);
          }
        }
      }

      final sortedLists = listsById.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _todoLists
        ..clear()
        ..addAll(sortedLists);
      _docIds
        ..clear()
        ..addAll(listsById.keys.toList());
      todoListsNotifier.value = List.unmodifiable(_todoLists);
    } on FirebaseException catch (e) {
      _todoLists.clear();
      _docIds.clear();
      todoListsNotifier.value = const <TodoList>[];
      throw e;
    } catch (_) {
      _todoLists.clear();
      _docIds.clear();
      todoListsNotifier.value = const <TodoList>[];
    }
  }

  static Future<void> addTodoList(TodoList todoList) async {
    try {
      if (_backendOverride != null) {
        // create uses backend override
        await _backendOverride!.add(todoList);
      } else {
        await _userTodoRef().push().set(todoList.toRealtimeMap());
      }
      await loadTodoLists();
    } on FirebaseException catch (e) {
      throw Exception(_mapDatabaseError(e));
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
      if (_backendOverride != null) {
        await _backendOverride!.update(docId, todoList);
      } else {
        await _userTodoRef().child(docId).update(todoList.toRealtimeMap());
      }
      await loadTodoLists();
    } on FirebaseException catch (e) {
      throw Exception(_mapDatabaseError(e));
    } catch (e) {
      throw Exception(
        'Connection error. Please check your internet connection and try again.',
      );
    }
  }

  static Future<void> updateTodoListById(String docId, TodoList todoList) async {
    if (docId.isEmpty) return;
    try {
      if (_backendOverride != null) {
        await _backendOverride!.update(docId, todoList);
      } else {
        await _userTodoRef().child(docId).update(todoList.toRealtimeMap());
      }
      await loadTodoLists();
    } on FirebaseException catch (e) {
      throw Exception(_mapDatabaseError(e));
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
      if (_backendOverride != null) {
        await _backendOverride!.remove(docId);
      } else {
        await _userTodoRef().child(docId).remove();
      }
      _todoLists.removeAt(index);
      _docIds.removeAt(index);
      todoListsNotifier.value = List.unmodifiable(_todoLists);
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
    todoListsNotifier.value = List.unmodifiable(_todoLists);

    if (listIndex < 0 || listIndex >= _docIds.length) return;
    final docId = _docIds[listIndex];
    try {
      if (_backendOverride != null) {
        await _backendOverride!.updateItems(
          docId,
          updatedItems.map((e) => e.toMap()).toList(),
        );
      } else {
        await _userTodoRef().child(docId).update({
          'items': updatedItems.map((e) => e.toMap()).toList(),
          'timestamp': ServerValue.timestamp,
        });
      }
    } catch (_) {}
  }

  static Future<void> clearAll() async {
    try {
      if (_backendOverride != null) {
        await _backendOverride!.clearAll();
      } else {
        await _userTodoRef().remove();
      }
      _todoLists.clear();
      _docIds.clear();
      todoListsNotifier.value = const <TodoList>[];
    } catch (_) {}
  }

  static void startRealtimeSync() {
    // Begin listening to Realtime Database changes and keep in-memory cache in sync
    _subscription?.cancel();
    try {
      if (_backendOverride != null) {
        _subscription = _backendOverride!.watch().listen((listsById) {
          final sorted = listsById.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _todoLists
            ..clear()
            ..addAll(sorted);
          _docIds
            ..clear()
            ..addAll(listsById.keys);
          todoListsNotifier.value = List.unmodifiable(_todoLists);
        });
      } else {
        _subscription = _userTodoRef().onValue.listen((event) {
          final listsById = <String, TodoList>{};
          final snap = event.snapshot;
          if (snap.value is Map) {
            final map = Map<String, dynamic>.from(snap.value as Map);
            map.forEach((key, value) {
              if (value is Map) {
                final data = Map<String, dynamic>.from(value as Map);
                listsById[key] = TodoList.fromRealtime(data);
              }
            });
          }
          final sorted = listsById.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _todoLists
            ..clear()
            ..addAll(sorted);
          _docIds
            ..clear()
            ..addAll(listsById.keys);
          todoListsNotifier.value = List.unmodifiable(_todoLists);
        });
      }
    } catch (_) {}
  }

  static void stopRealtimeSync() {
    // Stop the Realtime Database subscription
    _subscription?.cancel();
    _subscription = null;
  }

  static Future<Map<String, TodoList>> _loadFromFirestore() async {
    // Backward-compatibility: load existing lists from Firestore if RTDB is empty
    try {
      final query = await _userTodoCollection()
          .orderBy('timestamp', descending: true)
          .get();
      final result = <String, TodoList>{};
      for (final d in query.docs) {
        result[d.id] = TodoList.fromFirestore(d.data());
      }
      return result;
    } catch (_) {
      return <String, TodoList>{};
    }
  }

  static Future<void> _migrateFromFirestoreToRealtime(
      Map<String, TodoList> lists) async {
    // One-time migration: copy Firestore lists to Realtime Database under the same IDs
    final ref = _userTodoRef();
    final updates = <String, dynamic>{};
    lists.forEach((id, list) {
      updates[id] = list.toRealtimeMap();
    });
    await ref.update(updates);
  }

  static String _mapDatabaseError(FirebaseException e) {
    // Map Realtime Database errors to human-readable messages
    final code = e.code.toLowerCase();
    if (code.contains('permission')) return 'Permission denied';
    if (code.contains('network') || code.contains('disconnected')) {
      return 'Network error. Please check your internet connection.';
    }
    if (code.contains('timeout')) return 'Request timed out. Please retry.';
    return 'Database error: ${e.message ?? e.code}';
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

  static void debugSetBackend(TodoBackend backend) {
    // Testing hook: swap storage backend with an in-memory fake
    _backendOverride = backend;
  }
}

abstract class TodoBackend {
  Future<Map<String, TodoList>> load();
  Stream<Map<String, TodoList>> watch();
  Future<void> add(TodoList list);
  Future<void> update(String id, TodoList list);
  Future<void> updateItems(String id, List<Map<String, dynamic>> items);
  Future<void> remove(String id);
  Future<void> clearAll();
}

class FirestoreBackend implements TodoBackend {
  @override
  Future<Map<String, TodoList>> load() async {
    final query = await TodoStorage._userTodoCollection()
        .orderBy('timestamp', descending: true)
        .get();
    final result = <String, TodoList>{};
    for (final d in query.docs) {
      result[d.id] = TodoList.fromFirestore(d.data());
    }
    return result;
  }

  @override
  Stream<Map<String, TodoList>> watch() {
    return TodoStorage._userTodoCollection()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      final out = <String, TodoList>{};
      for (final d in snap.docs) {
        out[d.id] = TodoList.fromFirestore(d.data());
      }
      return out;
    });
  }

  @override
  Future<void> add(TodoList list) async {
    await TodoStorage._userTodoCollection().add(list.toFirestore());
  }

  @override
  Future<void> clearAll() async {
    final col = TodoStorage._userTodoCollection();
    final batch = FirebaseFirestore.instance.batch();
    final docs = await col.get();
    for (final d in docs.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  @override
  Future<void> remove(String id) async {
    await TodoStorage._userTodoCollection().doc(id).delete();
  }

  @override
  Future<void> update(String id, TodoList list) async {
    await TodoStorage._userTodoCollection().doc(id).update(list.toFirestore());
  }

  @override
  Future<void> updateItems(String id, List<Map<String, dynamic>> items) async {
    await TodoStorage._userTodoCollection().doc(id).update({
      'items': items,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
