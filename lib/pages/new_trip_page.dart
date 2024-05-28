import 'package:flutter/material.dart';
import 'package:budgetplannertracker/models/trip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewTripPage extends StatelessWidget {
  final db = FirebaseFirestore.instance;
  final Trip trip;

  NewTripPage({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _newTitleController = TextEditingController();
    _newTitleController.text = trip.title ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text('Create a New Trip'),
      ),
      body: Center(
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
            Text("Enter a Start Date"),
            Text("Enter a End Date"),
            ElevatedButton(
              onPressed: () async {
                trip.title = _newTitleController.text;
                
                await db.collection("Trips").add(trip.toJson());
              },
              child: Text("Submit"),
            )
          ],
        ),
      ),
    );
  }
}
