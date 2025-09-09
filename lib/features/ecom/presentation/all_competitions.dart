import 'package:flutter/material.dart';
import 'package:orca/core/utils/bottom_sheet.dart';
import 'package:sizer/sizer.dart';
import 'package:orca/core/utils/colors.dart';

class AllCompetitionsPage extends StatefulWidget {
  final CustomDrawerController drawerController;
  final ValueNotifier<Widget> drawerContentNotifier;

  const AllCompetitionsPage({required this.drawerController, required this.drawerContentNotifier, super.key});

  @override
  State<AllCompetitionsPage> createState() => _AllCompetitionsPageState();
}

class _AllCompetitionsPageState extends State<AllCompetitionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        backgroundColor: darkgreen,
        title: Text(
          'All Competitions',
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.sp),
        child: ListView.separated(
          itemCount: 5,
          separatorBuilder: (_, __) => SizedBox(height: 16.sp),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                widget.drawerController.openToMin();
                widget.drawerContentNotifier.value = buildCompetitionsDrawerContent(
                    title: 'All Kerala Inter College Tournament',
                    imagePath: 'imagePath',
                    context: context,
                    location: 'Greenfield International Stadium',
                    time: "04:30PM",
                    date: DateTime(2025, 05, 24),
                    rules: 'Matches will follow ICC T20 format. Knockout rounds, official umpires, and scoring sheets will be provided. Bring your own gear.');
              },
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/images/cricket.jpg",
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Cricket Mania $index", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text("Greenfield Stadium · 04:30 PM", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
