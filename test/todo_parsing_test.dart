import 'package:flutter_test/flutter_test.dart';
import 'package:personal_application/Databases/todo_storage.dart';

void main() {
  test('fromRealtime parses Map<dynamic,dynamic> items', () {
    final now = DateTime.now().toIso8601String();
    final data = {
      'name': 'X',
      'date': '2025-11-13',
      'items': [
        {
          'id': 'i1',
          'title': 'Task',
          'isCompleted': false,
          'createdAt': now,
          'listNumber': 1,
        },
      ],
      'createdAt': now,
    };

    final itemsDyn = (data['items'] as List)
        .map((e) => Map<dynamic, dynamic>.from(e as Map))
        .toList();
    final dataDyn = Map<String, dynamic>.from(data);
    dataDyn['items'] = itemsDyn;

    final list = TodoList.fromRealtime(dataDyn);
    expect(list.items.length, 1);
    expect(list.items.first.title, 'Task');
  });

  test('fromFirestore parses items robustly', () {
    final now = DateTime.now().toIso8601String();
    final data = {
      'name': 'Y',
      'date': '2025-11-13',
      'items': [
        {
          'id': 'i2',
          'title': 'Done',
          'isCompleted': true,
          'createdAt': now,
          'listNumber': 2,
        },
      ],
      'createdAt': now,
    };

    final list = TodoList.fromFirestore(Map<String, dynamic>.from(data));
    expect(list.items.length, 1);
    expect(list.items.first.isCompleted, true);
  });
}