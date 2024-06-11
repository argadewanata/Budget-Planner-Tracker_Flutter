import 'package:budgetplannertracker/models/trip.dart';
import 'package:budgetplannertracker/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripService {
  final _auth = AuthService();
  late DocumentReference _db;

  TripService() {
    _db = FirebaseFirestore.instance
        .collection('Users')
        .doc(_auth.getCurrentUserId());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSnapshot() {
    return _db.collection('Trips').snapshots();
  }

  Future create(Trip trip) {
    return _db.collection('Trips').add(trip.toJson());
  }

  Future update(Trip trip, String tripId) {
    return _db.collection('Trips').doc(tripId).update(trip.toJson());
  }

  Future delete(String tripId) {
    return _db.collection('Trips').doc(tripId).delete();
  }
}
