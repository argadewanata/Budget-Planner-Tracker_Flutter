import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  String? title;
  DateTime? startDate;
  DateTime? endDate;
  int? budget;
  String? travelType;

  Trip(
      {this.title, this.startDate, this.endDate, this.budget, this.travelType});

  Map<String, dynamic> toJson() => {
        'title': title,
        'startDate': startDate,
        'endDate': endDate,
        'budget': budget,
        'travelType': travelType,
      };

  Trip.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        startDate = (json['startDate'] as Timestamp).toDate(),
        endDate = (json['endDate'] as Timestamp).toDate(),
        budget = json['budget'],
        travelType = json['travelType'];
}
