import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:sizer/sizer.dart';

class UpcomingCompetitions extends StatefulWidget {
  const UpcomingCompetitions({super.key});

  @override
  State<UpcomingCompetitions> createState() => _UpcomingCompetitionsState();
}

class _UpcomingCompetitionsState extends State<UpcomingCompetitions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: whitet50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: whitet150),
                SizedBox(width: 8.sp),
                Expanded(
                  child: Text(
                    "Search here",
                    style: TextStyle(color: whitet150, fontSize: 14.sp),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Upcoming Competitions',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
