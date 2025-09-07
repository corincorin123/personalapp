import 'package:flutter/material.dart';
import 'package:personal_application/Diary/note_storage.dart';
import 'package:personal_application/Diary/noteTaking.dart';

class Diaryscreen extends StatefulWidget {
  static const String id = "Diaryscreen";
  const Diaryscreen({super.key});

  @override
  State<Diaryscreen> createState() => _DiaryscreenState();
}

class _DiaryscreenState extends State<Diaryscreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    await NoteStorage.loadNotes();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deleteNote(int index) async {
    await NoteStorage.removeNote(index);
    setState(() {});
  }

  void _editNote(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Notetaking(noteIndex: index)),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA0D2EB),
      appBar: AppBar(
        title: const Text(
          'History',
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
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: NoteStorage.notes.isEmpty
                  ? const Center(
                      child: Text(
                        'No notes yet. Tap the + button to create your first note!',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: NoteStorage.notes.length,
                      itemBuilder: (context, index) {
                        final note = NoteStorage.notes[index];
                        return GestureDetector(
                          onTap: () => _editNote(index),
                          child: HistoryNoteCard(
                            title: note.title,
                            date: note.date,
                            name: note.name,
                            onDelete: () => _deleteNote(index),
                          ),
                        );
                      },
                    ),
            ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Notetaking()),
          ).then((_) => setState(() {}));
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.edit_outlined, color: Colors.black, size: 32),
        ),
      ),
    );
  }
}

class HistoryNoteCard extends StatelessWidget {
  final String title;
  final String date;
  final String name;
  final VoidCallback onDelete;

  const HistoryNoteCard({
    super.key,
    required this.title,
    required this.date,
    required this.name,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'By: $name',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(date, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }
}
