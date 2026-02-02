import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/fitness/data/exercise_service.dart';
import 'package:orca/features/fitness/domain/exercise_model.dart';
import 'package:orca/features/fitness/presentations/workout_page.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AllWorkouts extends StatefulWidget {
  const AllWorkouts({super.key});

  @override
  State<AllWorkouts> createState() => _AllWorkoutsState();
}

class _AllWorkoutsState extends State<AllWorkouts> {
  final ExerciseService _exerciseService = ExerciseService();

  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];

  bool _isLoading = true;
  String _error = "";
  String _searchQuery = "";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.loadAuthData();

      if (auth.token == null) {
        setState(() {
          _isLoading = false;
          _error = "Not authenticated. Please log in again.";
        });
        return;
      }

      debugPrint("🔄 Fetching all workouts...");
      final list = await _exerciseService.fetchExercises(auth.token!);
      debugPrint("✅ Loaded ${list.length} workouts in AllWorkouts");

      setState(() {
        _exercises = list;
        _applyFilter();
        _isLoading = false;
        _error = "";
      });
    } catch (e) {
      debugPrint("❌ Error loading workouts in AllWorkouts: $e");
      setState(() {
        _isLoading = false;
        _error = "Failed to load workouts. Please try again.";
      });
    }
  }

  void _applyFilter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredExercises = List.from(_exercises);
    } else {
      final lower = _searchQuery.toLowerCase();
      _filteredExercises = _exercises
          .where((e) => e.name.toLowerCase().contains(lower))
          .toList();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'All Workouts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
              child: Container(
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
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _applyFilter();
                          });
                        },
                        style: TextStyle(color: Colors.white, fontSize: 14.sp),
                        decoration: InputDecoration(
                          isCollapsed: true,
                          border: InputBorder.none,
                          hintText: "Search here",
                          hintStyle: TextStyle(color: whitet150, fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 🧠 Body content (loading / error / list)
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: green),
                    )
                  : _error.isNotEmpty
                      ? Center(
                          child: Text(
                            _error,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      : _filteredExercises.isEmpty
                          ? const Center(
                              child: Text(
                                "No workouts found",
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _filteredExercises.length,
                              separatorBuilder: (context, index) {
                                return sizedfive(context);
                              },
                              itemBuilder: (context, index) {
                                final ex = _filteredExercises[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          // if later WorkoutPage takes Exercise, you can pass it here
                                          return const WorkoutPage();
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 17.sp, vertical: 6.sp),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15.sp, vertical: 12.sp),
                                    decoration: BoxDecoration(
                                      color: white.withAlpha(20),
                                      borderRadius: BorderRadius.circular(10.sp),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(8.sp),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: ex.imageUrl != null &&
                                                    ex.imageUrl!.isNotEmpty
                                                ? NetworkImage(ex.imageUrl!)
                                                    as ImageProvider
                                                : const AssetImage(
                                                    'assets/images/gym.png'),
                                          ),
                                        ),
                                        sizedwten(context),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ex.name,
                                                style: TextStyle(
                                                  color: const Color(0xFFB9F708),
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                ex.description ??
                                                    'No description provided',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.sp),
                                        Icon(
                                          Icons.play_circle_fill_rounded,
                                          color: const Color(0xFFB9F708),
                                          size: 20.sp,
                                          semanticLabel: 'Play Workout',
                                        ),
                                      ],
                                    ),
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
