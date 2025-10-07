import 'package:flutter/material.dart';
import 'package:personal_application/Databases/todo_storage.dart';

class TodoCreationScreen extends StatefulWidget {
  final int? todoListIndex;

  const TodoCreationScreen({super.key, this.todoListIndex});

  @override
  State<TodoCreationScreen> createState() => _TodoCreationScreenState();
}

class _TodoCreationScreenState extends State<TodoCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<TodoItem> _todoItems = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.todoListIndex != null) {
      final existingList = TodoStorage.todoLists[widget.todoListIndex!];
      _nameController.text = existingList.name;
      _dateController.text = existingList.date;
      _todoItems = List.from(existingList.items);
    } else {
      final now = DateTime.now();
      _dateController.text = '${now.day}/${now.month}/${now.year}';
      _todoItems = TodoStorage.getDefaultSelfCareItems();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveTodoList() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final todoList = TodoList(
      name: _nameController.text.trim(),
      date: _dateController.text.trim(),
      items: _todoItems,
      createdAt: DateTime.now(),
    );

    try {
      if (widget.todoListIndex != null) {
        await TodoStorage.updateTodoList(widget.todoListIndex!, todoList);
      } else {
        await TodoStorage.addTodoList(todoList);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addCustomItem(int listNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newItemTitle = '';
        final categoryName = TodoStorage.getListCategoryName(listNumber);

        return AlertDialog(
          title: Text('Add ${categoryName} Task'),
          content: TextField(
            onChanged: (value) => newItemTitle = value,
            decoration: InputDecoration(
              hintText: 'Enter your task...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            autofocus: true,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newItemTitle.trim().isNotEmpty) {
                  setState(() {
                    _todoItems.add(
                      TodoItem(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        title: newItemTitle.trim(),
                        isCompleted: false,
                        createdAt: DateTime.now(),
                        listNumber: listNumber,
                      ),
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  void _removeItem(String itemId) {
    setState(() {
      _todoItems.removeWhere((item) => item.id == itemId);
    });
  }

  void _toggleItem(String itemId) {
    setState(() {
      final index = _todoItems.indexWhere((item) => item.id == itemId);
      if (index != -1) {
        _todoItems[index] = _todoItems[index].copyWith(
          isCompleted: !_todoItems[index].isCompleted,
        );
      }
    });
  }

  List<TodoItem> _getItemsForList(int listNumber) {
    return _todoItems.where((item) => item.listNumber == listNumber).toList();
  }

  Color _getListColor(int listNumber) {
    switch (listNumber) {
      case 1:
        return const Color(0xFFB3D9FF);
      case 2:
        return const Color(0xFFE6CCFF);
      case 3:
        return const Color(0xFFE6CCFF);
      case 4:
        return const Color(0xFFB3D9FF);
      default:
        return Colors.grey[200]!;
    }
  }

  Widget _buildTodoList(int listNumber) {
    final items = _getItemsForList(listNumber);
    final listColor = _getListColor(listNumber);
    final title = TodoStorage.getListTitle(listNumber);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: listColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () => _addCustomItem(listNumber),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.add, size: 16),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.5),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Transform.scale(
                          scale: 0.7,
                          child: Checkbox(
                            value: item.isCompleted,
                            onChanged: (_) => _toggleItem(item.id),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            side: BorderSide.none,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: listColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _removeItem(item.id),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_isLoading) return;

        // Always go back to the main app, not login
        Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFA0D2EB),
        appBar: AppBar(
          title: Text(
            widget.todoListIndex != null
                ? 'Edit Checklist'
                : 'New Self-Care Checklist',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CHECKLIST DETAILS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Checklist Name',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Enter checklist name...',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _dateController,
                                decoration: InputDecoration(
                                  hintText: 'DD/MM/YYYY',
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.calendar_today,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                        children: [
                          _buildTodoList(1),
                          _buildTodoList(2),
                          _buildTodoList(3),
                          _buildTodoList(4),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveTodoList,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64B5F6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          widget.todoListIndex != null
                              ? 'Update Checklist'
                              : 'Save Checklist',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ), // End of PopScope child Scaffold
    ); // End of PopScope
  }
}
