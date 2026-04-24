import 'package:flutter/material.dart';

class DailyMissionPage extends StatelessWidget {
  const DailyMissionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Daily Missions",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () {
            Navigator.pop(context); // go back to previous page
          },
        ),
      ),
      body: Center(child: Text("Here you can see all missions")),
    );
  }
}
