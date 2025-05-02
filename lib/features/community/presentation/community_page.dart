import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:orca/core/utils/bottom_sheet.dart';
import 'package:orca/core/utils/colors.dart';

class CommunityPage extends StatefulWidget {
  final CustomDrawerController drawerController;
  final ValueNotifier<Widget> drawerContentNotifier;

  const CommunityPage({super.key, required this.drawerController, required this.drawerContentNotifier});
  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Recommendations',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GuideCard(
                      title: "Himalayan Trek",
                      duration: "12 Days",
                      difficulty: "Hard",
                      imagePath: "assets/images/trek.jpg",
                      onTap: () {
                        widget.drawerController.openToMin();

                        widget.drawerContentNotifier.value = buildTrekDrawerContent(
                          imagePath: "assets/images/trek.jpg",
                          title: "Sar Pass Trek", context: context,
                          location: 'Himachal Pradesh, India',
                          // description: "12 Days | Hard Difficulty\n\nEnjoy the breathtaking adventure...",
                          duration: '14 Days',
                          // difficulty: 'Hard',
                          // onApply: (){},
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GuideCard(
                      title: "Spiti Expeditions",
                      duration: "7 Days",
                      difficulty: "Moderate",
                      imagePath: "assets/images/spiti.jpg",
                      onTap: () {
                        widget.drawerController.openToMin();

                        widget.drawerContentNotifier.value = buildBikeRideDrawerContent(title: 'Spiti Expedition', context: context, startLocation: 'Chandigarh', endLocation: 'Manali', date: DateTime(2025, 05, 20), time: '09:00 PM', distance: '450KM', difficulty: 'Moderate', rideType: 'Bike');
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _sectionTitle("Upcoming Competitions"),
              SizedBox(height: 14.sp),
              ChallengeCard(drawerContentNotifier: widget.drawerContentNotifier, drawerController: widget.drawerController,),
              SizedBox(height: 20),
              _sectionTitle("Trekking Guides"),
              SizedBox(height: 10),
              SmallGuideCard(
                title: "Everest Base Camp",
                imagePath: "assets/images/trek.jpg",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        Text('View All', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
        Icon(
          Icons.arrow_right,
          size: 30,
          color: green,
        )
      ],
    );
  }
}

class GuideCard extends StatelessWidget {
  final String title;
  final String duration;
  final String difficulty;
  final String imagePath;
  final VoidCallback onTap;

  const GuideCard({
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                imagePath,
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
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text("⏳ $duration   🔥 $difficulty", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChallengeCard extends StatelessWidget {
  final CustomDrawerController drawerController;
  final ValueNotifier<Widget> drawerContentNotifier;
  
  const ChallengeCard({
    Key? key,
    required this.drawerController,
    required this.drawerContentNotifier,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        drawerController.openToMin();
        drawerContentNotifier.value = buildCompetitionsDrawerContent(title: 'All Kerala Inter College Tournament', imagePath: 'imagePath', context: context, location: 'Greenfield International Stadium', time: "04:30PM", date: DateTime(2025, 05, 24), rules: 'Matches will follow ICC T20 format. Knockout rounds, official umpires, and scoring sheets will be provided. Bring your own gear.');
      },
      child: Container(
        height: 180,
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
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 180,
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
              child: Text("Cricket Mania", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// Small Trek Guide Card
class SmallGuideCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const SmallGuideCard({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Text(title, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
