import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_application/Databases/note_storage.dart';
import 'package:personal_application/Diary/noteTaking.dart';
import 'package:personal_application/utils/responsive_helper.dart';

class Diaryscreen extends StatefulWidget {
  static const String id = "Diaryscreen";
  const Diaryscreen({super.key});

  @override
  State<Diaryscreen> createState() => _DiaryscreenState();
}

class _DiaryscreenState extends State<Diaryscreen> {
  final DiaryService _diaryService = DiaryService();

  Future<void> _deleteNote(String docId) async {
    try {
      await _diaryService.deleteNote(docId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note deleted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmAndDeleteNote(String docId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: Text(
          'Are you sure you want to delete "${title.isEmpty ? 'this note' : title}"? This action cannot be undone.',
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
      await _deleteNote(docId);
    }
  }

  void _editNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Notetaking(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA0D2EB),
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 28),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _diaryService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: ResponsiveHelper.getResponsiveIconSize(context, 80),
                      color: Colors.grey[400],
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        16,
                      ),
                    ),
                    Text(
                      'Connection Error',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          20,
                        ),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(context, 8),
                    ),
                    Text(
                      'Unable to connect to the server.\nPlease check your internet connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(
                          context,
                          14,
                        ),
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveSpacing(
                        context,
                        16,
                      ),
                    ),
                    SizedBox(
                      height: ResponsiveHelper.getResponsiveButtonHeight(
                        context,
                      ),
                      child: ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data?.docs ?? [];

          if (notes.isEmpty) {
            return Center(
              child: Padding(
                padding: ResponsiveHelper.getResponsivePadding(context),
                child: Text(
                  'No notes yet. Tap the + button to create your first note!',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      16,
                    ),
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Padding(
            padding: ResponsiveHelper.getResponsivePadding(context),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
                crossAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  20,
                ),
                mainAxisSpacing: ResponsiveHelper.getResponsiveSpacing(
                  context,
                  20,
                ),
                childAspectRatio: ResponsiveHelper.getGridChildAspectRatio(
                  context,
                ),
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final noteDoc = notes[index];
                final note = Note.fromFirestore(noteDoc);

                return GestureDetector(
                  onTap: () => _editNote(note),
                  child: HistoryNoteCard(
                    title: note.title,
                    date: note.date,
                    name: note.name,
                    onDelete: () => _confirmAndDeleteNote(note.id!, note.title),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Notetaking()),
          );
        },
        child: Container(
          width: ResponsiveHelper.getResponsiveFABSize(context),
          height: ResponsiveHelper.getResponsiveFABSize(context),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.edit_outlined,
            color: Colors.black,
            size: ResponsiveHelper.getResponsiveIconSize(context, 32),
          ),
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
            padding: ResponsiveHelper.getResponsivePadding(context).copyWith(
              top: ResponsiveHelper.getResponsiveSpacing(context, 12),
              bottom: ResponsiveHelper.getResponsiveSpacing(context, 12),
              left: ResponsiveHelper.getResponsiveSpacing(context, 12),
              right: ResponsiveHelper.getResponsiveSpacing(context, 12),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      16,
                    ),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: ResponsiveHelper.getResponsiveSpacing(context, 8),
                ),
                Text(
                  'By: $name',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      12,
                    ),
                    color: Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: ResponsiveHelper.getResponsiveIconSize(
                          context,
                          20,
                        ),
                      ),
                      onPressed: onDelete,
                    ),
                  ],
                ),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getResponsiveFontSize(
                      context,
                      11,
                    ),
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 10)),
        Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 4)),
        Text(
          date,
          style: TextStyle(
            color: Colors.black54,
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
          ),
        ),
      ],
    );
  }
}
