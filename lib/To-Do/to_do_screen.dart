import 'package:flutter/material.dart';
import 'package:personal_application/Databases/todo_storage.dart';
import 'package:personal_application/To-Do/todo_creation_screen.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTodoLists();
  }

  Future<void> _loadTodoLists() async {
    await TodoStorage.loadTodoLists();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteTodoList(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete checklist?'),
        content: const Text(
          'This will permanently remove the checklist. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await TodoStorage.removeTodoList(index);
      if (mounted) setState(() {});
    }
  }

  void _editTodoList(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoCreationScreen(todoListIndex: index),
      ),
    ).then((_) => setState(() {}));
  }

  void _createNewTodoList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TodoCreationScreen()),
    ).then((_) => setState(() {}));
  }

  int _getCompletedItemsCount(List<TodoItem> items) {
    return items.where((item) => item.isCompleted).length;
  }

  double _getCompletionPercentage(List<TodoItem> items) {
    if (items.isEmpty) return 0.0;
    return _getCompletedItemsCount(items) / items.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA0D2EB),
      appBar: AppBar(
        title: const Text(
          'Self-Care Checklists',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TodoStorage.todoLists.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.checklist_outlined,
                              size: 64,
                              color: Colors.black54,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No checklists yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap the + button to create your first checklist',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: TodoStorage.todoLists.length,
                        itemBuilder: (context, index) {
                          final todoList = TodoStorage.todoLists[index];
                          final completedCount = _getCompletedItemsCount(
                            todoList.items,
                          );
                          final totalCount = todoList.items.length;
                          final completionPercentage = _getCompletionPercentage(
                            todoList.items,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () => _editTodoList(index),
                              child: TodoListCard(
                                name: todoList.name,
                                date: todoList.date,
                                completedTasks: completedCount,
                                totalTasks: totalCount,
                                completionPercentage: completionPercentage,
                                onDelete: () => _deleteTodoList(index),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
      floatingActionButton: GestureDetector(
        onTap: _createNewTodoList,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.add, color: Colors.black, size: 32),
        ),
      ),
    );
  }
}

class TodoListCard extends StatelessWidget {
  final String name;
  final String date;
  final int completedTasks;
  final int totalTasks;
  final double completionPercentage;
  final VoidCallback onDelete;

  const TodoListCard({
    super.key,
    required this.name,
    required this.date,
    required this.completedTasks,
    required this.totalTasks,
    required this.completionPercentage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              date,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.grey[300],
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: completionPercentage,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: completionPercentage == 1.0
                              ? Colors.green
                              : const Color(0xFF64B5F6),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$completedTasks/$totalTasks',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: completionPercentage == 1.0
                        ? Colors.green.shade700
                        : Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${(completionPercentage * 100).toInt()}% Complete',
                    style: TextStyle(
                      fontSize: 12,
                      color: completionPercentage == 1.0
                          ? Colors.green.shade600
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (completionPercentage == 1.0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 10, color: Colors.green),
                        SizedBox(width: 2),
                        Text(
                          'Done',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
