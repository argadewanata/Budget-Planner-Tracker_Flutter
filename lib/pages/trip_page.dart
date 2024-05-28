import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgetplannertracker/models/trip.dart';

class TripPage extends StatelessWidget {
  final List<Trip> tripsList = [
    Trip('Jakarta', DateTime.now(), DateTime.now(), 100000, 'Car'),
    Trip('Bandung', DateTime.now(), DateTime.now(), 250000, 'Car'),
    Trip('Semarang', DateTime.now(), DateTime.now(), 450000, 'Car'),
    Trip('Yogyakarta', DateTime.now(), DateTime.now(), 500000, 'Bus'),
    Trip('Surabaya', DateTime.now(), DateTime.now(), 750000, 'Plane'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: tripsList.length,
        itemBuilder: (BuildContext context, int index) => buildTripCard(context, index),
      ),
    );
  }

  Widget buildTripCard(BuildContext context, int index) {
    final trip_plan = tripsList[index];
    final NumberFormat currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      trip_plan.title ?? "Unknown",
                      style: TextStyle(fontSize: 25.0),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      "${DateFormat('dd/MM/yyyy').format(trip_plan.startDate ?? DateTime.now())} - ${DateFormat('dd/MM/yyyy').format(trip_plan.endDate ?? DateTime.now())}",
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      currencyFormatter.format(trip_plan.budget ?? 0),
                      style: TextStyle(fontSize: 23.0),
                    ),
                    Spacer(),
                    Text(trip_plan.travelType ?? "Unknown"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}