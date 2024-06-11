import 'package:budgetplannertracker/models/note.dart';
import 'package:budgetplannertracker/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteService {
  final _auth = AuthService();
  late DocumentReference _db;

  NoteService() {
    _db = FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.getCurrentUserId());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSnapshot(String tripId) {
    return _db.collection('Trips').doc(tripId).collection('notes').snapshots();
  }

  Future create(String tripId, Note note) {
    return _db
        .collection('Trips')
        .doc(tripId)
        .collection('notes')
        .add(note.toJson());
  }

  Future update(String tripId, Note note) {
    return _db
        .collection('Trips')
        .doc(tripId)
        .collection('notes')
        .doc(note.id)
        .update(note.toJson());
  }

  Future delete(String tripId, String? noteId) {
    return _db
        .collection('Trips')
        .doc(tripId)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}
