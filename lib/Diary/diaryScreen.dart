import 'package:flutter/material.dart';
import 'package:personal_application/Diary/notetaking.dart';
import '../main.dart';

class Diaryscreen extends StatefulWidget {
  static const String id = "Diaryscreen";
  const Diaryscreen({super.key});

  @override
  State<Diaryscreen> createState() => _DiaryscreenState();
}

class _DiaryscreenState extends State<Diaryscreen> {
  @override
  Widget build(BuildContext context) {
    print('Building Diaryscreen with ${NoteStorage.notes.length} notes');

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
      body: Padding(
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.7,
                ),
                itemCount: NoteStorage.notes.length,
                itemBuilder: (context, index) {
                  final note = NoteStorage.notes[index];
                  return HistoryNoteCard(
                    title: note['title'] ?? 'Untitled',
                    date: note['date'] ?? 'No date',
                    name: note['name'] ?? 'No name',
                    isSelected: index == 0,
                  );
                },
              ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () async {
          print('FAB tapped, navigating to Notetaking');

          final result = await Navigator.pushNamed(context, Notetaking.id);

          print('Returned from Notetaking with result: $result');

          if (result == true) {
            print('Refreshing Diaryscreen');
            setState(() {});
          }
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
  final bool isSelected;

  const HistoryNoteCard({
    super.key,
    required this.title,
    required this.date,
    required this.name,
    this.isSelected = false,
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
              border: isSelected
                  ? Border.all(color: Colors.purple, width: 3)
                  : null,
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
