import 'package:budgetplannertracker/services/trip_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:budgetplannertracker/models/trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:budgetplannertracker/pages/expense_track.dart';

class NewTripPage extends StatefulWidget {
  final Trip trip;
  final String? tripId;

  NewTripPage({Key? key, required this.trip, this.tripId}) : super(key: key);

  @override
  State<NewTripPage> createState() => _NewTripPageState();
}

class _NewTripPageState extends State<NewTripPage> {
  final _tripService = TripService();
  final TextEditingController _newTitleController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 3));
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );
  bool _isFormatting = false;
  String _travelType = 'Car';

  @override
  void initState() {
    super.initState();
    _newTitleController.text = widget.trip.title ?? "";
    _budgetController.text = widget.trip.budget != null
        ? _currencyFormat.format(widget.trip.budget).replaceAll(',', '.')
        : "";
    _startDate = widget.trip.startDate ?? DateTime.now();
    _endDate = widget.trip.endDate ?? DateTime.now().add(Duration(days: 3));
    _startDateController.text = _dateFormat.format(_startDate);
    _endDateController.text = _dateFormat.format(_endDate);
    _travelType = widget.trip.travelType ?? 'Car';
    _budgetController.addListener(_formatBudget);
  }

  @override
  void dispose() {
    _newTitleController.dispose();
    _budgetController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _formatBudget() {
    if (_isFormatting) return;

    setState(() {
      _isFormatting = true;

      final String text =
          _budgetController.text.replaceAll('.', '').replaceAll('Rp', '');
      final int value = int.tryParse(text) ?? 0;
      final String formatted =
          _currencyFormat.format(value).replaceAll(',', '.');
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
        title: Text(widget.tripId == null ? 'Create a New Trip' : 'Edit Trip'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Where do you want to go?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _newTitleController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Destination',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "How much is your budget?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Budget',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "When are you planning to travel?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
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
                      _startDateController.text =
                          _dateFormat.format(_startDate);
                      _endDateController.text = _dateFormat.format(_endDate);
                    });
                  }
                },
                icon: Icon(Icons.calendar_today, color: Colors.blue),
                label: Text('Pick Date Range'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Start Date',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _endDateController,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'End Date',
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "How will you travel?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Column(
                    children: [
                      Icon(Icons.directions_car,
                          color:
                              _travelType == 'Car' ? Colors.blue : Colors.grey),
                      Radio<String>(
                        value: 'Car',
                        groupValue: _travelType,
                        onChanged: (String? value) {
                          setState(() {
                            _travelType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.flight,
                          color: _travelType == 'Plane'
                              ? Colors.blue
                              : Colors.grey),
                      Radio<String>(
                        value: 'Plane',
                        groupValue: _travelType,
                        onChanged: (String? value) {
                          setState(() {
                            _travelType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.directions_bus,
                          color:
                              _travelType == 'Bus' ? Colors.blue : Colors.grey),
                      Radio<String>(
                        value: 'Bus',
                        groupValue: _travelType,
                        onChanged: (String? value) {
                          setState(() {
                            _travelType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.train,
                          color: _travelType == 'Train'
                              ? Colors.blue
                              : Colors.grey),
                      Radio<String>(
                        value: 'Train',
                        groupValue: _travelType,
                        onChanged: (String? value) {
                          setState(() {
                            _travelType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    widget.trip.title = _newTitleController.text;
                    widget.trip.startDate = _startDate;
                    widget.trip.endDate = _endDate;
                    widget.trip.budget = int.tryParse(_budgetController.text
                        .replaceAll('.', '')
                        .replaceAll('Rp', ''));
                    widget.trip.travelType = _travelType;

                    if (widget.tripId == null) {
                      _tripService.create(widget.trip);
                    } else {
                      _tripService.update(widget.trip, widget.tripId!);
                    }
                    Navigator.pop(context, widget.trip);
                  },
                  child: Text("Submit"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
