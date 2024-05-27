import 'package:flutter/material.dart';
import 'package:budgetplannertracker/pages/profile_page.dart';
import 'package:budgetplannertracker/pages/save_page.dart';
import 'package:budgetplannertracker/pages/travel_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    TravelPage(),
    SavePage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Travel Budget Tracker"),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.card_travel),
            label: "Travel Plan",
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.attach_money),
            label: "Save",
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.account_circle),
            label: "Profile",
          ),
        ]
      ),
    );
  }

  void onTabTapped(int index){
    setState(() {
      _currentIndex = index;
    });

  }
}

