import 'package:flutter/material.dart';

import '../main.dart';

// IMPORTANT: Remove the NoteStorage class from this file if you have it
// The NoteStorage should only exist in your main.dart file

class Notetaking extends StatefulWidget {
  static const String id = "Notetaking";
  const Notetaking({super.key});

  @override
  State<Notetaking> createState() => _NotetakingState();
}

class _NotetakingState extends State<Notetaking> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isLoading = false; // Add loading state

  @override
  void initState() {
    super.initState();
    // Set today's date by default
    _dateController.text = _getCurrentDate();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  Future<void> _saveNote() async {
    print('Save button pressed'); // Debug print

    if (_titleController.text.trim().isEmpty) {
      print('Title is empty, showing error'); // Debug print
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for your note'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Start loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate some processing time (like saving to database)
      await Future.delayed(const Duration(seconds: 2));

      // Add the note using NoteStorage
      print(
        'Adding note with title: ${_titleController.text.trim()}',
      ); // Debug print

      NoteStorage.addNote(
        title: _titleController.text.trim(),
        name: _nameController.text.trim().isEmpty
            ? 'Anonymous'
            : _nameController.text.trim(),
        date: _dateController.text.trim(),
        content: _contentController.text.trim(),
      );

      print('Note added successfully'); // Debug print

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back and indicate that a note was saved
      print('Navigating back'); // Debug print
      Navigator.pop(context, true);
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Stop loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _isLoading
              ? null
              : () {
                  print('Back button pressed'); // Debug print
                  Navigator.pop(context);
                },
        ),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveNote,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ],
      ),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isLoading, // Disable interaction during loading
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.cloud, color: Colors.blue, size: 100),
                      const SizedBox(width: 30),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoField(
                              "Name:",
                              _nameController,
                              "Enter your name",
                            ),
                            const SizedBox(height: 15),
                            _buildInfoField(
                              "Date:",
                              _dateController,
                              "Enter date",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'TITLE',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              hintText: 'Enter your note title',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.black54),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _contentController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: 'Start writing your note here...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(color: Colors.black54),
                        ),
                        style: const TextStyle(fontSize: 16, height: 1.5),
                        textAlignVertical: TextAlignVertical.top,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Full-screen loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Saving your note...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    String hint,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black54),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black54),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              hintStyle: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}
