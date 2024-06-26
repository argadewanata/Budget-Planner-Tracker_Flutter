import 'package:budgetplannertracker/pages/new_trip_page.dart';
import 'package:flutter/material.dart';
import 'package:budgetplannertracker/pages/profile_page.dart';
import 'package:budgetplannertracker/pages/trip_page.dart';
import 'package:budgetplannertracker/models/trip.dart';
import 'package:budgetplannertracker/pages/current_trip_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    CurrentTripPage(),
    TripPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final newTrip = Trip(); // Default constructor with no arguments
    return Scaffold(
      appBar: AppBar(
        title: Text("Travel Budget Tracker"),
      ),
      body: _children[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewTripPage(trip: newTrip),
                  ),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.travel_explore),
            label: "Current Trip",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: "All Trip",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
