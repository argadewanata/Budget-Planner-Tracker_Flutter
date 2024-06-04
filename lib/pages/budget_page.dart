// import 'package:flutter/material.dart';
// import 'package:budgetplannertracker/services/firestore_budget.dart'; // Tambahkan import ini
// import 'package:firebase_core/firebase_core.dart'; // Tambahkan import ini
// import 'package:budgetplannertracker/firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:budgetplannertracker/models/trip.dart';
//
//
//
// class budgetPage extends StatefulWidget{
//   final String trip;
//   budgetPage({Key? key, required this.trip}) : super(key: key);
//   State<budgetPage> createState() => _budgetPageState();
// }
//
//
// class _budgetPageState extends State<budgetPage>{
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Budget Tracker'),
//         backgroundColor: Colors.blue[200],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance.collection('Trips').snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           final tripsList = snapshot.data!.docs.map((doc) {
//             return Trip.fromJson(doc.data() as Map<String, dynamic>, doc.id);
//           }).toList();
//
//           if (tripsList.isEmpty) {
//             return Center(
//               child: Text(
//                 'No expenses available',
//                 style: TextStyle(fontSize: 18, color: Colors.blue[200]),
//               ),
//             );
//           }
//
//           return ListView.builder(
//             itemCount: tripsList.length,
//             itemBuilder: (BuildContext context, int index) => buildExpenseCard(
//                 context, expenses[index], widget.trip),
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => AddExpensePage(trip: widget.trip),
//             ),
//           );
//         },
//         child: Icon(Icons.add),
//         backgroundColor: Colors.blue[200],
//       ),
//     );}
//
//
//
// }
