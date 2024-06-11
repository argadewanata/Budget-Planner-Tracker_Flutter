import 'package:budgetplannertracker/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseService {
  final _auth = AuthService();
  late DocumentReference _db;

  ExpenseService() {
    _db = FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.getCurrentUserId());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSnapshot(String tripId) {
    return _db.collection('Trips/$tripId/expenses').snapshots();
  }

  Future delete(String tripId, String expenseId) {
    return _db.collection('Trips/$tripId/expenses').doc(expenseId).delete();
  }
}
