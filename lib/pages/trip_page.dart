import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgetplannertracker/models/trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TripPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Trips').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final tripsList = snapshot.data!.docs.map((doc) {
            return Trip.fromJson(doc.data() as Map<String, dynamic>);
          }).toList();

          if (tripsList.isEmpty) {
            return Center(
              child: Text(
                'No trips available',
                style: TextStyle(fontSize: 18, color: Colors.blue[200]),
              ),
            );
          }

          return ListView.builder(
            itemCount: tripsList.length,
            itemBuilder: (BuildContext context, int index) => buildTripCard(context, tripsList[index]),
          );
        },
      ),
    );
  }

  Widget buildTripCard(BuildContext context, Trip trip) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.location_on, color: Colors.blue[600]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      trip.title ?? "Unknown Destination",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Icon(Icons.date_range, color: Colors.blue[600]),
                  SizedBox(width: 8),
                  Text(
                    formatDateRange(trip.startDate, trip.endDate),
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Icon(Icons.attach_money, color: Colors.blue[600]),
                  SizedBox(width: 8),
                  Text(
                    currencyFormatter.format(trip.budget ?? 0),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  getTravelTypeIcon(trip.travelType),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String formatDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return "Unknown Date";

    final DateFormat dayFormat = DateFormat('dd');
    final DateFormat monthYearFormat = DateFormat('MMM yyyy');
    final DateFormat fullFormat = DateFormat('dd MMM yyyy');

    if (startDate.year == endDate.year) {
      if (startDate.month == endDate.month) {
        return '${dayFormat.format(startDate)} - ${dayFormat.format(endDate)} ${monthYearFormat.format(endDate)}';
      } else {
        return '${dayFormat.format(startDate)} ${DateFormat('MMM').format(startDate)} - ${dayFormat.format(endDate)} ${monthYearFormat.format(endDate)}';
      }
    } else {
      return '${fullFormat.format(startDate)} - ${fullFormat.format(endDate)}';
    }
  }

  Widget getTravelTypeIcon(String? travelType) {
    switch (travelType) {
      case 'Car':
        return Icon(Icons.directions_car, color: Colors.blue[600], size: 30);
      case 'Plane':
        return Icon(Icons.flight, color: Colors.blue[600], size: 30);
      case 'Bus':
        return Icon(Icons.directions_bus, color: Colors.blue[600], size: 30);
      case 'Train':
        return Icon(Icons.train, color: Colors.blue[600], size: 30);
      default:
        return Icon(Icons.help_outline, color: Colors.blue[200], size: 30);
    }
  }
}
