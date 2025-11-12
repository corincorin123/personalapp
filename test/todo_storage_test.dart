import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_application/Databases/todo_storage.dart';

class FakeBackend implements TodoBackend {
  final Map<String, TodoList> _store = <String, TodoList>{};
  final StreamController<Map<String, TodoList>> _controller =
      StreamController<Map<String, TodoList>>.broadcast();
  int _seq = 0;

  void _emit() {
    _controller.add(Map<String, TodoList>.from(_store));
  }

  @override
  Future<void> add(TodoList list) async {
    _seq += 1;
    final id = '${DateTime.now().millisecondsSinceEpoch}_$_seq';
    _store[id] = list;
    _emit();
  }

  @override
  Future<void> clearAll() async {
    _store.clear();
    _emit();
  }

  @override
  Future<Map<String, TodoList>> load() async {
    return Map<String, TodoList>.from(_store);
  }

  @override
  Future<void> remove(String id) async {
    _store.remove(id);
    _emit();
  }

  @override
  Stream<Map<String, TodoList>> watch() => _controller.stream;

  @override
  Future<void> update(String id, TodoList list) async {
    _store[id] = list;
    _emit();
  }

  @override
  Future<void> updateItems(
      String id, List<Map<String, dynamic>> items) async {
    final current = _store[id];
    if (current == null) return;
    final updatedItems = items
        .map((e) => TodoItem.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    _store[id] = current.copyWith(items: updatedItems);
    _emit();
  }
}

void main() {
  group('TodoStorage with FakeBackend', () {
    late FakeBackend backend;

    setUp(() async {
      backend = FakeBackend();
      TodoStorage.debugSetBackend(backend);
      await TodoStorage.clearAll();
    });

    test('Add and load todo list', () async {
      final list = TodoList(
        name: 'List A',
        date: '2025-11-12',
        items: <TodoItem>[],
        createdAt: DateTime.now(),
      );
      await TodoStorage.addTodoList(list);
      await TodoStorage.loadTodoLists();
      expect(TodoStorage.todoLists.length, 1);
      expect(TodoStorage.todoLists.first.name, 'List A');
    });

    test('Update todo list', () async {
      final list = TodoList(
        name: 'Original',
        date: '2025-11-12',
        items: <TodoItem>[],
        createdAt: DateTime.now(),
      );
      await TodoStorage.addTodoList(list);
      await TodoStorage.loadTodoLists();

      final updated = list.copyWith(name: 'Updated');
      await TodoStorage.updateTodoList(0, updated);
      await TodoStorage.loadTodoLists();
      expect(TodoStorage.todoLists.first.name, 'Updated');
    });

    test('Toggle item completion', () async {
      final item = TodoItem(
        id: 'i1',
        title: 'Task',
        isCompleted: false,
        createdAt: DateTime.now(),
        listNumber: 1,
      );
      final list = TodoList(
        name: 'Has Items',
        date: '2025-11-12',
        items: <TodoItem>[item],
        createdAt: DateTime.now(),
      );
      await TodoStorage.addTodoList(list);
      await TodoStorage.loadTodoLists();

      await TodoStorage.toggleTodoItem(0, 'i1');
      await TodoStorage.loadTodoLists();
      expect(TodoStorage.todoLists.first.items.first.isCompleted, true);
    });

    test('Remove and clear all', () async {
      final listA = TodoList(
        name: 'A',
        date: '2025-11-12',
        items: <TodoItem>[],
        createdAt: DateTime.now(),
      );
      final listB = TodoList(
        name: 'B',
        date: '2025-11-12',
        items: <TodoItem>[],
        createdAt: DateTime.now(),
      );
      await TodoStorage.addTodoList(listA);
      await TodoStorage.addTodoList(listB);
      await TodoStorage.loadTodoLists();
      expect(TodoStorage.todoLists.length, 2);

      await TodoStorage.removeTodoList(0);
      await TodoStorage.loadTodoLists();
      expect(TodoStorage.todoLists.length, 1);

      await TodoStorage.clearAll();
      await TodoStorage.loadTodoLists();
      expect(TodoStorage.todoLists.isEmpty, true);
    });

    test('Realtime sync emits changes', () async {
      TodoStorage.startRealtimeSync();
      final changes = <int>[];
      void listener() {
        changes.add(TodoStorage.todoLists.length);
      }
      TodoStorage.todoListsListenable.addListener(listener);

      final list = TodoList(
        name: 'Realtime',
        date: '2025-11-12',
        items: <TodoItem>[],
        createdAt: DateTime.now(),
      );
      await TodoStorage.addTodoList(list);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(changes.contains(1), true);
      TodoStorage.stopRealtimeSync();
      TodoStorage.todoListsListenable.removeListener(listener);
    });
  });
}