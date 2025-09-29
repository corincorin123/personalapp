import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'listNumber': listNumber,
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
    id: json['id'],
    title: json['title'],
    isCompleted: json['isCompleted'],
    createdAt: DateTime.parse(json['createdAt']),
    listNumber: json['listNumber'],
  );
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

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date,
    'items': items.map((item) => item.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory TodoList.fromJson(Map<String, dynamic> json) => TodoList(
    name: json['name'],
    date: json['date'],
    items: (json['items'] as List)
        .map((item) => TodoItem.fromJson(item))
        .toList(),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class TodoStorage {
  static final List<TodoList> _todoLists = <TodoList>[];
  static const String _storageKey = 'todo_lists';

  static List<TodoList> get todoLists => List.unmodifiable(_todoLists);

  static Future<void> loadTodoLists() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todoListsJson = prefs.getString(_storageKey);

    if (todoListsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(todoListsJson);
        _todoLists.clear();
        _todoLists.addAll(
          decoded.map((item) => TodoList.fromJson(item)).toList(),
        );
      } catch (e) {
        _todoLists.clear();
      }
    }
  }

  static Future<void> _saveTodoLists() async {
    final prefs = await SharedPreferences.getInstance();
    final String todoListsJson = jsonEncode(
      _todoLists.map((list) => list.toJson()).toList(),
    );
    await prefs.setString(_storageKey, todoListsJson);
  }

  static Future<void> addTodoList(TodoList todoList) async {
    _todoLists.add(todoList);
    await _saveTodoLists();
  }

  static Future<void> updateTodoList(int index, TodoList todoList) async {
    if (index >= 0 && index < _todoLists.length) {
      _todoLists[index] = todoList;
      await _saveTodoLists();
    }
  }

  static Future<void> removeTodoList(int index) async {
    if (index >= 0 && index < _todoLists.length) {
      _todoLists.removeAt(index);
      await _saveTodoLists();
    }
  }

  static Future<void> toggleTodoItem(int listIndex, String itemId) async {
    if (listIndex >= 0 && listIndex < _todoLists.length) {
      final todoList = _todoLists[listIndex];
      final updatedItems = todoList.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isCompleted: !item.isCompleted);
        }
        return item;
      }).toList();

      _todoLists[listIndex] = todoList.copyWith(items: updatedItems);
      await _saveTodoLists();
    }
  }

  static Future<void> clearAll() async {
    _todoLists.clear();
    await _saveTodoLists();
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
