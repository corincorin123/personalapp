import 'package:flutter/material.dart';
import 'package:personal_application/Diary/note_storage.dart';
import 'package:personal_application/utils/responsive_helper.dart';

class Notetaking extends StatefulWidget {
  final Note? note;

  const Notetaking({super.key, this.note});

  @override
  State<Notetaking> createState() => _NotetakingState();
}

class _NotetakingState extends State<Notetaking> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final DiaryService _diaryService = DiaryService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      final note = widget.note!;
      _nameController.text = note.name;
      _dateController.text = note.date;
      _titleController.text = note.title;
      _contentController.text = note.content;
    } else {
      _dateController.text = _getCurrentDate();
    }
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
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for your note'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final note = Note(
        title: _titleController.text.trim(),
        name: _nameController.text.trim().isEmpty
            ? 'Anonymous'
            : _nameController.text.trim(),
        date: _dateController.text.trim(),
        content: _contentController.text.trim(),
      );

      if (widget.note != null) {
        await _diaryService.updateNote(widget.note!.id!, note);
      } else {
        await _diaryService.addNote(note);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
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
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: ResponsiveHelper.getResponsiveIconSize(context, 24),
          ),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        actions: [
          _isLoading
              ? Padding(
                  padding: ResponsiveHelper.getResponsivePadding(context),
                  child: SizedBox(
                    width: ResponsiveHelper.getResponsiveSpacing(context, 20),
                    height: ResponsiveHelper.getResponsiveSpacing(context, 20),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveNote,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: ResponsiveHelper.getResponsiveFontSize(
                        context,
                        16,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ],
      ),
      body: Center(
        child: Container(
          width: ResponsiveHelper.getMaxContentWidth(context),
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: _isLoading,
                child: Padding(
                  padding: ResponsiveHelper.getResponsivePadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ResponsiveHelper.isMobile(context)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Icon(
                                    Icons.cloud,
                                    color: Colors.blue,
                                    size:
                                        ResponsiveHelper.getResponsiveIconSize(
                                          context,
                                          80,
                                        ),
                                  ),
                                ),
                                SizedBox(
                                  height: ResponsiveHelper.getResponsiveSpacing(
                                    context,
                                    20,
                                  ),
                                ),
                                _buildInfoField(
                                  "Name:",
                                  _nameController,
                                  "Enter your name",
                                ),
                                SizedBox(
                                  height: ResponsiveHelper.getResponsiveSpacing(
                                    context,
                                    15,
                                  ),
                                ),
                                _buildInfoField(
                                  "Date:",
                                  _dateController,
                                  "Enter date",
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.cloud,
                                  color: Colors.blue,
                                  size: ResponsiveHelper.getResponsiveIconSize(
                                    context,
                                    100,
                                  ),
                                ),
                                SizedBox(
                                  width: ResponsiveHelper.getResponsiveSpacing(
                                    context,
                                    30,
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoField(
                                        "Name:",
                                        _nameController,
                                        "Enter your name",
                                      ),
                                      SizedBox(
                                        height:
                                            ResponsiveHelper.getResponsiveSpacing(
                                              context,
                                              15,
                                            ),
                                      ),
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
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          40,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            15,
                          ),
                          vertical: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            15,
                          ),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'TITLE',
                              style: TextStyle(
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      18,
                                    ),
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              width: ResponsiveHelper.getResponsiveSpacing(
                                context,
                                15,
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: 'Enter your note title',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Colors.black54,
                                    fontSize:
                                        ResponsiveHelper.getResponsiveFontSize(
                                          context,
                                          14,
                                        ),
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getResponsiveFontSize(
                                        context,
                                        16,
                                      ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getResponsiveSpacing(
                          context,
                          30,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(
                            ResponsiveHelper.getResponsiveSpacing(context, 15),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: _contentController,
                            maxLines: null,
                            expands: true,
                            decoration: InputDecoration(
                              hintText: 'Start writing your note here...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                color: Colors.black54,
                                fontSize:
                                    ResponsiveHelper.getResponsiveFontSize(
                                      context,
                                      14,
                                    ),
                              ),
                            ),
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(
                                context,
                                16,
                              ),
                              height: 1.5,
                            ),
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue,
                          ),
                          strokeWidth: 3,
                        ),
                        SizedBox(
                          height: ResponsiveHelper.getResponsiveSpacing(
                            context,
                            20,
                          ),
                        ),
                        Text(
                          'Saving your note...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ResponsiveHelper.getResponsiveFontSize(
                              context,
                              16,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
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
          style: TextStyle(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 16),
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 10)),
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
              hintStyle: TextStyle(
                color: Colors.black54,
                fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
              ),
            ),
            style: TextStyle(
              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            ),
          ),
        ),
      ],
    );
  }
}
