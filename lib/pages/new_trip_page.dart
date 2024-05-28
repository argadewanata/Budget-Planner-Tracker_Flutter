import 'package:flutter/material.dart';
import 'package:budgetplannertracker/models/trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // Add this import for date formatting

class NewTripPage extends StatefulWidget {
  final Trip trip;

  NewTripPage({Key? key, required this.trip}) : super(key: key);

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final db = FirebaseFirestore.instance;
  final TextEditingController _newTitleController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 7));
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd'); // DateFormat for displaying dates
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  bool _isFormatting = false; // Add a flag to prevent formatting loop

  @override
  void initState() {
    super.initState();
    _newTitleController.text = widget.trip.title ?? "";
    _budgetController.addListener(_formatBudget);  // Add a listener to the budget controller
  }

  @override
  void dispose() {
    _newTitleController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _formatBudget() {
    if (_isFormatting) return;

    setState(() {
      _isFormatting = true;

      final String text = _budgetController.text.replaceAll('.', '').replaceAll('Rp', '');
      final int value = int.tryParse(text) ?? 0;
      final String formatted = _currencyFormat.format(value).replaceAll(',', '.');

      _budgetController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );

      _isFormatting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create a New Trip'),
      ),
      body: Center(
        child: SingleChildScrollView( // Add SingleChildScrollView to prevent overflow
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Enter a New Destination"),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextField(
                  controller: _newTitleController,
                ),
              ),
              Text("Enter Budget"),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextField(
                  controller: _budgetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter budget",
                  ),
                ),
              ),
              Text("Select Start and End Date"),
              ElevatedButton(
                onPressed: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                    initialDateRange: DateTimeRange(
                      start: _startDate,
                      end: _endDate,
                    ),
                  );
                  if (picked != null) {
                    setState(() {
                      _startDate = picked.start;
                      _endDate = picked.end;
                    });
                    print("Start Date: $_startDate");
                    print("End Date: $_endDate");
                  }
                },
                child: const Icon(Icons.calendar_today_outlined, color: Colors.green),
              ),
              Text("Start Date: ${_dateFormat.format(_startDate)}"),
              Text("End Date: ${_dateFormat.format(_endDate)}"),
              ElevatedButton(
                onPressed: () async {
                  widget.trip.title = _newTitleController.text;
                  widget.trip.startDate = _startDate;
                  widget.trip.endDate = _endDate;
                  widget.trip.budget = int.tryParse(_budgetController.text.replaceAll('.', '').replaceAll('Rp', ''));  // Parse the budget input as int

                  await db.collection("Trips").add(widget.trip.toJson());
                },
                child: Text("Submit"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
