import 'package:flutter/material.dart';
import 'package:orca/core/utils/bottom_sheet.dart';
import 'package:sizer/sizer.dart';
import 'package:orca/core/utils/colors.dart';

class AllCompetitionsPage extends StatefulWidget {
  final CustomDrawerController drawerController;
  final ValueNotifier<Widget> drawerContentNotifier;

  const AllCompetitionsPage({
    required this.drawerController,
    required this.drawerContentNotifier,
    super.key,
  });

  @override
  State<AllCompetitionsPage> createState() => _AllCompetitionsPageState();
}

class _AllCompetitionsPageState extends State<AllCompetitionsPage> {
  // sample data
  final List<Map<String, dynamic>> competitions = [
    {
      'title': 'All Kerala Inter College Tournament',
      'image': 'assets/images/cricket.jpg',
      'location': 'Greenfield Stadium',
      'time': '04:30 PM',
      'date': DateTime(2025, 5, 24),
      'category': 'Cricket',
    },
    {
      'title': 'Kerala Football League Finals',
      'image': 'assets/images/football.jpg',
      'location': 'Jawaharlal Nehru Stadium',
      'time': '07:00 PM',
      'date': DateTime(2025, 6, 10),
      'category': 'Football',
    },
  ];

  final List<String> categories = [
    'Cricket',
    'Football',
    'Athletics',
    'Badminton',
  ];

  String selectedCategory = 'Cricket';

  @override
  Widget build(BuildContext context) {
    final filteredCompetitions = competitions
        .where((comp) => comp['category'] == selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🏁 Header
                Padding(
                  padding: EdgeInsets.only(bottom: 1.5.h),
                  child: Text(
                    "Competitions",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),

                /// 🔥 Upcoming competitions header + See all
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Upcoming Competitions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {

                      },
                      child: Text(
                        "See all",
                        style: TextStyle(
                          color: green,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                /// Featured competition card
                if (competitions.isNotEmpty)
                  _buildCompetitionCard(
                    title: competitions.first['title'],
                    imagePath: competitions.first['image'],
                    location: competitions.first['location'],
                    time: competitions.first['time'],
                    date: competitions.first['date'],
                  )
                else
                  _noCompetitionsMessage(),

                SizedBox(height: 3.5.h),

                /// 🏷️ Explore Categories
                Text(
                  "Explore Categories",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),

                Wrap(
                  spacing: 2.2.w,
                  runSpacing: 1.5.h,
                  children: categories.map((cat) {
                    bool isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 4.w, vertical: 1.2.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: isSelected
                              ? green.withOpacity(0.9)
                              : darkgreen.withOpacity(0.4),
                          border: Border.all(
                            color:
                                isSelected ? green : green.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 3.h),

                /// 🧾 Category-specific competitions
                Text(
                  "$selectedCategory Competitions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),

                if (filteredCompetitions.isNotEmpty)
                  Column(
                    children: filteredCompetitions.map((comp) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.5.h),
                        child: _buildCompetitionCard(
                          title: comp['title'],
                          imagePath: comp['image'],
                          location: comp['location'],
                          time: comp['time'],
                          date: comp['date'],
                        ),
                      );
                    }).toList(),
                  )
                else
                  _noCompetitionsMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _noCompetitionsMessage() {
    return Container(
      height: 17.h,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withAlpha(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        "No competitions at the moment 💤",
        style: TextStyle(color: Colors.white, fontSize: 12.5.sp),
      ),
    );
  }

  Widget _buildCompetitionCard({
    required String title,
    required String imagePath,
    required String location,
    required String time,
    required DateTime date,
  }) {
    return GestureDetector(
      onTap: () {
        widget.drawerController.openToMin();
        widget.drawerContentNotifier.value = buildCompetitionsDrawerContent(
          title: title,
          imagePath: imagePath,
          context: context,
          location: location,
          time: time,
          date: date,
          rules:
              'Matches will follow ICC T20 format. Knockout rounds, official umpires, and scoring sheets will be provided. Bring your own gear.',
        );
      },
      child: Container(
        height: 21.h, // slightly taller for more premium feel
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 21.h,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 21.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 1.5.h,
              left: 3.w,
              right: 3.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.3.h),
                        Text(
                          "$location · $time",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70, size: 14.sp),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
