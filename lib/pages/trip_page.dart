import 'package:budgetplannertracker/services/trip_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgetplannertracker/models/trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'trip_detail_page.dart';

class TripPage extends StatelessWidget {
  final _tripService = TripService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: _tripService.getSnapshot(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final currentDate = DateTime.now();
          final tripsList = snapshot.data!.docs.map((doc) {
            return Trip.fromJson(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          final pastTrips = tripsList
              .where((trip) => trip.endDate!.isBefore(currentDate))
              .toList();
          final futureTrips = tripsList
              .where((trip) => trip.startDate!.isAfter(currentDate))
              .toList();

          if (tripsList.isEmpty) {
            return Center(
              child: Text(
                'No trips available',
                style: TextStyle(fontSize: 18, color: Colors.blue[200]),
              ),
            );
          }

          return ListView(
            children: [
              buildCategorySection(context, 'Future Trips', futureTrips, false),
              buildCategorySection(context, 'Past Trips', pastTrips, true),
            ],
          );
        },
      ),
    );
  }

  Widget buildCategorySection(BuildContext context, String categoryTitle,
      List<Trip> trips, bool isPast) {
    if (trips.isEmpty) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryTitle,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          ...trips
              .map((trip) => buildTripCard(context, trip, trip.id!, isPast))
              .toList(),
        ],
      ),
    );
  }

  Widget buildTripCard(
      BuildContext context, Trip trip, String tripId, bool isPast) {
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        color: isPast ? Colors.grey[300] ?? Colors.grey : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    TripDetailPage(trip: trip, tripId: tripId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.location_on_outlined,
                        color: isPast ? Colors.grey : Colors.blue[600]!),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trip.title ?? "Unknown Destination",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isPast ? Colors.grey : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Icon(Icons.calendar_today_rounded,
                        color: isPast ? Colors.grey : Colors.blue[600]!),
                    SizedBox(width: 8),
                    Text(
                      formatDateRange(trip.startDate, trip.endDate),
                      style: TextStyle(
                          fontSize: 16,
                          color: isPast ? Colors.grey : Colors.black54),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Icon(Icons.attach_money,
                        color: isPast ? Colors.grey : Colors.blue[600]!),
                    SizedBox(width: 8),
                    Text(
                      currencyFormatter.format(trip.budget ?? 0),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: isPast ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    getTravelTypeIcon(trip.travelType, isPast),
                  ],
                ),
              ],
            ),
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

  Widget getTravelTypeIcon(String? travelType, bool isPast) {
    Color iconColor = isPast ? Colors.grey : Colors.blue[600]!;
    switch (travelType) {
      case 'Car':
        return Icon(Icons.directions_car, color: iconColor, size: 30);
      case 'Plane':
        return Icon(Icons.flight, color: iconColor, size: 30);
      case 'Bus':
        return Icon(Icons.directions_bus, color: iconColor, size: 30);
      case 'Train':
        return Icon(Icons.train, color: iconColor, size: 30);
      default:
        return Icon(Icons.help_outline,
            color: isPast ? Colors.grey : Colors.blue[200]!, size: 30);
    }
  }
}
