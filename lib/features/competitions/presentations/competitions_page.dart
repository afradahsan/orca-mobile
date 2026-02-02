import 'package:flutter/material.dart';
import 'package:orca/core/utils/bottom_sheet.dart';
import 'package:orca/features/competitions/data/competitions_model.dart';
import 'package:orca/features/competitions/data/competitions_service.dart';
import 'package:orca/features/competitions/presentations/all_competitions.dart';
import 'package:orca/features/competitions/presentations/competition_details.dart';
import 'package:sizer/sizer.dart';
import 'package:orca/core/utils/colors.dart';

class CompetitionsPage extends StatefulWidget {
  final CustomDrawerController drawerController;
  final ValueNotifier<Widget> drawerContentNotifier;

  const CompetitionsPage({
    required this.drawerController,
    required this.drawerContentNotifier,
    super.key,
  });

  @override
  State<CompetitionsPage> createState() => _CompetitionsPageState();
}

class _CompetitionsPageState extends State<CompetitionsPage> {
  List<Competition> competitions = [];
  bool isLoading = true;

  List<String> categories = [];

  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    fetchCompetitions();
  }

  Future<void> fetchCompetitions() async {
    try {
      final data = await CompetitionService().getCompetitions();

      final extractedCategories = data.expand((c) => c.category).toSet().toList();

      debugPrint("🔵 Competitions Loaded: ${data.length}");
      debugPrint("🔵 Competitions Data: ${data[0].image}");
      debugPrint("🔵 Categories: $extractedCategories");

      setState(() {
        competitions = data;
        categories = extractedCategories;
        selectedCategory = categories.isNotEmpty ? categories.first : "No Category";
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCompetitions = competitions.where((comp) => comp.category.contains(selectedCategory)).toList();

    return Scaffold(
      backgroundColor: darkgreen,
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: green),
              )
            : competitions.isEmpty
                ? Center(
                    child: Text(
                      "No competitions available",
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TITLE
                          Text(
                            "Competitions",
                            style: TextStyle(color: Colors.white, fontSize: 21.sp, fontWeight: FontWeight.w700),
                          ),

                          SizedBox(height: 2.h),

                          /// UPCOMING + SEE ALL
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Upcoming Competitions", style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600)),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AllCompetitions()),
                                  );
                                },
                                child: Text(
                                  "See all",
                                  style: TextStyle(
                                    color: green,
                                    fontSize: 13.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 2.h),

                          /// SWIPEABLE UPCOMING COMPETITIONS
                          SizedBox(
                            height: 23.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: competitions.length,
                              itemBuilder: (context, index) {
                                final comp = competitions[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => CompetitionDetailsPage(competition: comp,)),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 4.w),
                                    child: _buildCompetitionCard(
                                      title: comp.name,
                                      imagePath: comp.image.first,
                                      location: comp.place,
                                      time: comp.time,
                                      date: comp.date,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          SizedBox(height: 3.h),

                          /// CATEGORY TITLE
                          Text(
                            "Explore Categories",
                            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
                          ),

                          SizedBox(height: 2.h),

                          /// CATEGORY FILTER
                          Wrap(
                            spacing: 2.2.w,
                            runSpacing: 1.5.h,
                            children: categories.map((cat) {
                              bool isSelected = selectedCategory == cat;

                              return GestureDetector(
                                onTap: () => setState(() => selectedCategory = cat),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 220),
                                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: isSelected ? green : darkgreen.withOpacity(0.4),
                                    border: Border.all(
                                      color: isSelected ? green : green.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Text(cat, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w700)),
                                ),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: 3.h),

                          /// LIST FOR SELECTED CATEGORY
                          Text(
                            "$selectedCategory Competitions",
                            style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
                          ),

                          SizedBox(height: 2.h),

                          filteredCompetitions.isNotEmpty
                              ? Column(
                                  children: filteredCompetitions.map((comp) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => CompetitionDetailsPage(competition: comp,)),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(bottom: 2.5.h),
                                        child: _buildCompetitionCard(
                                          title: comp.name,
                                          imagePath: comp.image.first,
                                          location: comp.place,
                                          time: comp.time,
                                          date: comp.date,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              : _noCompetitionsMessage(),
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
      alignment: Alignment.center,
      child: Text(
        "No competitions at the moment 💤",
        style: TextStyle(color: Colors.white, fontSize: 13.sp),
      ),
    );
  }

  String fixCloudinary(String url) {
    if (url.contains("res.cloudinary.com")) {
      return url.replaceFirst("/upload/", "/upload/f_auto,q_auto,f_jpg/");
    }
    return url;
  }

  Widget _buildCompetitionCard({
    required String title,
    required String imagePath,
    required String location,
    required String time,
    required DateTime date,
  }) {
    return Container(
      width: 75.w,
      height: 23.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white10,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              fixCloudinary(imagePath),
              width: double.infinity,
              height: 23.h,
              fit: BoxFit.cover,
            ),
          ),
          Container(
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

          /// TEXT
          Positioned(
            bottom: 1.5.h,
            left: 3.w,
            right: 3.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 0.5.h),
                Text("$location · $time",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.sp,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
