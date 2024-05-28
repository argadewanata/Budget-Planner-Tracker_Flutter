import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  String? id;
  String? title;
  DateTime? startDate;
  DateTime? endDate;
  int? budget;
  String? travelType;

  Trip(
      {this.id,
      this.title,
      this.startDate,
      this.endDate,
      this.budget,
      this.travelType});

  Map<String, dynamic> toJson() => {
        'title': title,
        'startDate': startDate,
        'endDate': endDate,
        'budget': budget,
        'travelType': travelType,
      };

  Trip.fromJson(Map<String, dynamic> json, String documentId)
      : id = documentId,
        title = json['title'],
        startDate = (json['startDate'] as Timestamp).toDate(),
        endDate = (json['endDate'] as Timestamp).toDate(),
        budget = json['budget'],
        travelType = json['travelType'];
}
