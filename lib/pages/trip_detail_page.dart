import 'package:budgetplannertracker/widgets/notes.dart';
import 'package:flutter/material.dart';
import 'package:budgetplannertracker/models/trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'new_trip_page.dart';
import 'expense_track.dart';

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
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _trip = widget.trip;
  }

  @override
  Widget build(BuildContext context) {
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
                      Row(
                        children: <Widget>[
                          Icon(Icons.info_outline, color: Colors.blue[600]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Trip Detail",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
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
              buildBudgetProgressBar(context, _trip),
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
                    children: [
                      Row(
                        children: <Widget>[
                          Icon(Icons.attach_money, color: Colors.blue[600]),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Expenses Detail",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      StreamBuilder<List<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('Trips')
                            .doc(widget.tripId)
                            .collection('expenses')
                            .snapshots()
                            .map((snapshot) =>
                                snapshot.docs.map((e) => e.data()).toList()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Error loading expenses'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ExpenseTrack(trip: widget.tripId),
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Center(
                                  child: Text(
                                    'No expenses found. Tap to add.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }

                          final expenses = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: expenses.length,
                                itemBuilder: (context, index) {
                                  final expense = expenses[index];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ExpenseTrack(trip: widget.tripId),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      title: Text(
                                        expense['description'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${expense['category']} - ${currencyFormatter.format(int.parse(expense['amount']))}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ExpenseTrack(
                                                          trip: widget.tripId),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('Trips')
                                                  .doc(widget.tripId)
                                                  .collection('expenses')
                                                  .doc(expense['id'])
                                                  .delete();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              NotesWidget(tripId: widget.tripId),
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

  Widget buildBudgetProgressBar(BuildContext context, Trip trip) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Trips')
          .doc(trip.id)
          .collection('expenses')
          .snapshots()
          .map((snapshot) => snapshot.docs.map((e) => e.data()).toList()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final expenses = snapshot.data!;
        final totalExpense = expenses.fold(0, (prev, expense) {
          final amount = int.tryParse(expense['amount']) ?? 0;
          return prev + amount;
        });
        final budget = trip.budget ?? 0;
        final balance = budget - totalExpense;
        final progress = totalExpense / budget;
        final percentageUsed = (progress * 100).toStringAsFixed(2);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance: ${currencyFormatter.format(balance)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.red[100],
              color: progress > 0.75
                  ? Colors.red
                  : (progress > 0.5 ? Colors.orange : Colors.green),
              minHeight: 20,
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Expense: ${currencyFormatter.format(totalExpense)}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '$percentageUsed%',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
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
