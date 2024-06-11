import 'package:budgetplannertracker/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _auth = AuthService();
  late DocumentReference _db;

  FirestoreService() {
    _db = FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.getCurrentUserId());
  }

  Future<void> addExpense(
      String tripId, String amount, String description, String category) async {
    try {
      await _db.collection('Trips/$tripId/expenses').add({
        'amount': amount,
        'description': description,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding expense: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getExpenses(String tripId) {
    return _db
        .collection('Trips/$tripId/expenses')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
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

  Future<void> deleteExpense(tripId, String id) async {
    try {
      await _db.collection('Trips/$tripId/expenses').doc(id).delete();
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }

  Future<void> updateExpense(String tripId, String id, String amount,
      String description, String category) async {
    try {
      await _db.collection('Trips/$tripId/expenses').doc(id).update({
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
