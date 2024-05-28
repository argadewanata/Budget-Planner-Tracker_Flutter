import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addExpense(String amount, String description, String category) async {
    try {
      await _db.collection('expenses').add({
        'amount': amount,
        'description': description,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding expense: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getExpenses() {
    return _db.collection('expenses').orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'amount': doc['amount'],
          'description': doc['description'],
          'category': doc['category'],
          'timestamp': doc['timestamp'],
        };
      }).toList();
    });
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _db.collection('expenses').doc(id).delete();
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }

  Future<void> updateExpense(String id, String amount, String description, String category) async {
    try {
      await _db.collection('expenses').doc(id).update({
        'amount': amount,
        'description': description,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating expense: $e');
    }
  }
}
