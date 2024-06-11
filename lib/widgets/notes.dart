import 'package:budgetplannertracker/models/note.dart';
import 'package:budgetplannertracker/services/note_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotesWidget extends StatelessWidget {
  final String tripId;
  final db = FirebaseFirestore.instance;
  final _noteService = NoteService();

  NotesWidget({super.key, required this.tripId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Todo List",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Note>>(
              stream: _noteService.getSnapshot(tripId).map((snapshot) =>
                  snapshot.docs
                      .map((e) => Note.fromJson(e.data(), e.id))
                      .toList()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading todo list'));
                }

                final List<Note> notes = snapshot.data!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...notes.map((note) => buildNoteCard(context, note)),
                    const SizedBox(height: 8),
                    buildNoteCreateButton(context),
                  ],
                );
              })
        ],
      ),
    );
  }

  Widget buildNoteCard(BuildContext context, Note note) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(note.note),
        tileColor: Colors.deepPurple[50],
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => buildNoteTapDialog(context, note),
          );
        },
        leading: Checkbox(
          value: note.isFinished,
          onChanged: (value) {
            note.isFinished = value!;
            _noteService.update(tripId, note);
          },
        ),
      ),
    );
  }

  Widget buildNoteCreateButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => buildNoteCreateDialog(context),
        );
      },
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48)),
      ),
      child: const Text('Add Todo'),
    );
  }

  Widget buildNoteCreateDialog(BuildContext context) {
    final note = Note(
      note: '',
      isFinished: false,
    );

    return SimpleDialog(
      title: const Text('Add Todo'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(labelText: 'Todo'),
            onChanged: (value) {
              note.note = value;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              _noteService.create(tripId, note);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ),
      ],
    );
  }

  Widget buildNoteTapDialog(BuildContext context, Note note) {
    return SimpleDialog(
      title: const Text('Edit Todo'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: TextEditingController(text: note.note),
            decoration: const InputDecoration(labelText: 'Todo'),
            onChanged: (value) {
              note.note = value;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red[100]),
                ),
                onPressed: () {
                  _noteService.delete(tripId, note.id);
                  Navigator.pop(context);
                },
                child: const Text('Delete'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _noteService.update(tripId, note);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
