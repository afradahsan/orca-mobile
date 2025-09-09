import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:sizer/sizer.dart';

class FitnessGuidePage extends StatefulWidget {
  @override
  State<FitnessGuidePage> createState() => _FitnessGuidePageState();
}

class _FitnessGuidePageState extends State<FitnessGuidePage> {
  final List<Map<String, String>> content = [
    {
      'title': 'Gain weight the right way',
      'category': 'Workout',
      'duration': '3 mins',
    },
    {
      'title': 'Mindful Breathing',
      'category': 'Mindfulness',
      'duration': '10 mins',
    },
    {
      'title': 'Post-Workout Nutrition',
      'category': 'Nutrition',
      'duration': '5 mins',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Fitness Guide', style: TextStyle(color: Colors.white, fontFamily: GoogleFonts.bebasNeue().fontFamily, letterSpacing: 2)),
        centerTitle: true,
        leading: Icon(Icons.arrow_back, color: white,),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Daily Tip
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Tip: Stay hydrated during workouts to improve performance!",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // List of Guides
            Expanded(
              child: ListView.builder(
                itemCount: content.length,
                itemBuilder: (context, index) {
                  final item = content[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.file_copy_rounded, color: Colors.white, size: 20.sp),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['title']!, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              Text('${item['category']}', style: TextStyle(color: Colors.grey)),
                              // • ${item['duration']}
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.white)
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}