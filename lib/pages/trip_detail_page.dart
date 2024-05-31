import 'package:flutter/material.dart';
import 'package:budgetplannertracker/models/trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'new_trip_page.dart';

class TripDetailPage extends StatefulWidget {
  final Trip trip;
  final String tripId;

  TripDetailPage({required this.trip, required this.tripId});

  @override
  _TripDetailPageState createState() => _TripDetailPageState();
}

class _TripDetailPageState extends State<TripDetailPage> {
  final db = FirebaseFirestore.instance;
  late Trip _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NewTripPage(trip: _trip, tripId: widget.tripId),
                ),
              );

              if (result != null && result is Trip) {
                setState(() {
                  _trip = result;
                });
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await db.collection('Trips').doc(widget.tripId).delete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Text(
                  _trip.title ?? "Unknown Destination",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      buildDetailRow(
                          Icon(Icons.date_range, color: Colors.blue[600]),
                          'Travel Dates',
                          formatDateRange(_trip.startDate, _trip.endDate)),
                      SizedBox(height: 10),
                      buildDetailRow(
                          Icon(Icons.attach_money, color: Colors.blue[600]),
                          'Budget',
                          currencyFormatter.format(_trip.budget ?? 0)),
                      SizedBox(height: 10),
                      buildDetailRow(getTravelTypeIcon(_trip.travelType),
                          'Travel Type', _trip.travelType ?? "Unknown"),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(Widget icon, String label, String value) {
    return Row(
      children: <Widget>[
        icon,
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget getTravelTypeIcon(String? travelType) {
    switch (travelType) {
      case 'Car':
        return Icon(Icons.directions_car, color: Colors.blue[600]);
      case 'Plane':
        return Icon(Icons.flight, color: Colors.blue[600]);
      case 'Bus':
        return Icon(Icons.directions_bus, color: Colors.blue[600]);
      case 'Train':
        return Icon(Icons.train, color: Colors.blue[600]);
      default:
        return Icon(Icons.help_outline, color: Colors.blue[200]);
    }
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
}
