import 'dart:async';
import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/competitions/data/competitions_model.dart';
import 'package:orca/features/competitions/data/competitions_service.dart';
import 'package:orca/features/fitness/data/workout_log_service.dart';
import 'package:orca/features/fitness/domain/workout_log.dart';
import 'package:orca/features/home/data/banner_model.dart';
import 'package:orca/features/home/data/banner_service.dart';
import 'package:orca/features/notifications/presentation/notification_bell.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class HomePage extends StatefulWidget {
  final Function(int index)? onTabSelected;

  const HomePage({
    super.key,
    this.onTabSelected,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _heroController = PageController();
  int _currentHeroIndex = 0;
  Timer? _heroTimer;

  List<Competition> _backendCompetitions = [];
  List<WorkoutLogModel> _userWorkoutLogs = [];
  List<Map<String, dynamic>> _heroBanners = [];

  final List<Map<String, dynamic>> _defaultBanners = [
    {
      'title': 'ORCA 30-DAY FITNESS CHALLENGE',
      'subtitle': '2,481 athletes participating • 500 OS Points',
      'tag': 'YOUR NEXT CHALLENGE',
      'cta': 'JOIN CHALLENGE →',
      'tabIndex': 2,
      'image': 'assets/images/challenge.png',
      'isNetwork': false,
    },
    {
      'title': 'NEW SEASON PRO MERCH DROP',
      'subtitle': 'OS Club Official 2026 Collection',
      'tag': 'HOT DROP',
      'cta': 'SHOP MERCH →',
      'tabIndex': 1,
      'image': 'assets/images/Puma-magmax.png',
      'isNetwork': false,
    },
    {
      'title': 'LEH-LADAKH HIGH EXPEDITION',
      'subtitle': '12 Athletes Registered • 5 Days Left',
      'tag': 'FEATURED EVENT',
      'cta': 'VIEW EVENT →',
      'tabIndex': 3,
      'image': 'assets/images/spiti.jpg',
      'isNetwork': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _heroBanners = List.from(_defaultBanners);
    _startHeroTimer();
    _fetchBackendData();
  }

  void _startHeroTimer() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_heroController.hasClients && _heroBanners.isNotEmpty) {
        final nextIndex = (_currentHeroIndex + 1) % _heroBanners.length;
        _heroController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _fetchBackendData() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final token = auth.token ?? '';

      final competitionService = CompetitionService();
      final bannerService = BannerService();
      final workoutLogService = WorkoutLogService();

      final results = await Future.wait([
        bannerService.fetchAdminBanners().catchError((e) {
          debugPrint('Error fetching admin banners: $e');
          return <HomeBanner>[];
        }),
        competitionService.getCompetitions().catchError((e) {
          debugPrint('Error fetching competitions: $e');
          return <Competition>[];
        }),
        token.isNotEmpty
            ? workoutLogService.getWorkoutLogs(token).catchError((e) {
                debugPrint('Error fetching user workout logs: $e');
                return <WorkoutLogModel>[];
              })
            : Future.value(<WorkoutLogModel>[]),
      ]);

      if (mounted) {
        final fetchedAdminBanners = results[0] as List<HomeBanner>;
        final fetchedCompetitions = results[1] as List<Competition>;
        final fetchedWorkoutLogs = results[2] as List<WorkoutLogModel>;

        List<Map<String, dynamic>> updatedBanners = [];

        if (fetchedAdminBanners.isNotEmpty) {
          updatedBanners = fetchedAdminBanners.map((b) {
            final isNetwork =
                b.image.startsWith('http://') || b.image.startsWith('https://');
            return {
              'title': b.title.isNotEmpty ? b.title : 'ORCA FEATURED EVENT',
              'subtitle': b.subtitle.isNotEmpty
                  ? b.subtitle
                  : 'Exclusive Community Milestone',
              'tag': b.tag.isNotEmpty ? b.tag : 'FEATURED',
              'cta': b.cta.isNotEmpty ? '${b.cta} →' : 'EXPLORE →',
              'tabIndex': b.tabIndex,
              'image': b.image,
              'isNetwork': isNetwork,
            };
          }).toList();
        } else {
          updatedBanners = List.from(_defaultBanners);
        }

        setState(() {
          _heroBanners = updatedBanners;
          _backendCompetitions = fetchedCompetitions;
          _userWorkoutLogs = fetchedWorkoutLogs;
        });
      }
    } catch (e) {
      debugPrint('Error loading backend data: $e');
    }
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroController.dispose();
    super.dispose();
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final bool hasActiveWorkout = _userWorkoutLogs.isNotEmpty;
    final bool hasNearbyContent = _backendCompetitions.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F17), // Matte Dark Slate Background
      body: RefreshIndicator(
        onRefresh: _fetchBackendData,
        color: green,
        backgroundColor: const Color(0xFF161C26),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER (Simple greeting with enlarged 22.sp text)
              _buildSimpleHeader(auth),

              SizedBox(height: 16.sp),

              // 2. HERO BANNER (Primary promotional/action area)
              if (_heroBanners.isNotEmpty) _buildHeroBannerCarousel(),

              SizedBox(height: 26.sp),

              // 3. CORE ACTIONS (FOR YOU Section with Extra Large Readability)
              _buildAsymmetricCoreActions(),

              SizedBox(height: 26.sp),

              // 4. CONTINUE WORKOUT (STRICTLY CONDITIONAL - ONLY IF ACTIVE WORKOUT EXISTS)
              if (hasActiveWorkout) ...[
                _buildActiveWorkoutCard(_userWorkoutLogs.first),
                SizedBox(height: 26.sp),
              ],

              // 5. NEAR YOU (STRICTLY CONDITIONAL - ONLY IF NEARBY CONTENT EXISTS)
              if (hasNearbyContent) ...[
                _buildNearYouDiscoverySection(),
                SizedBox(height: 26.sp),
              ],

              SizedBox(height: 36.sp),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Simple Header with Extra Large 22.sp Ultra-Readable Greeting Text
  Widget _buildSimpleHeader(AuthProvider auth) {
    final greeting = _getTimeBasedGreeting();
    const String userName = 'Afrad';

    return Padding(
      padding: EdgeInsets.only(left: 16.sp, right: 16.sp, top: 14.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, $userName 👋',
                style: TextStyle(
                  color: const Color(0xFFF8FAFC),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3.sp,
                  shadows: const [
                    Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
              SizedBox(height: 3.sp),
              Text(
                'Ready for your next milestone?',
                style: TextStyle(
                  color: const Color(0xFFE2E8F0),
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  shadows: const [
                    Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const NotificationBell(
            iconColor: Colors.white,
            iconSize: 22,
          ),
        ],
      ),
    );
  }

  /// 2. Primary Promotional Hero Carousel with Extra Large Typography
  Widget _buildHeroBannerCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 205,
          child: PageView.builder(
            controller: _heroController,
            onPageChanged: (index) {
              setState(() {
                _currentHeroIndex = index;
              });
            },
            itemCount: _heroBanners.length,
            itemBuilder: (context, index) {
              final banner = _heroBanners[index];
              return AnimatedBuilder(
                animation: _heroController,
                builder: (context, child) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.sp),
                    child: child,
                  );
                },
                child: _buildHeroCardItem(banner),
              );
            },
          ),
        ),
        SizedBox(height: 10.sp),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_heroBanners.length, (index) {
            final isSelected = _currentHeroIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 3.5,
              width: isSelected ? 24 : 8,
              decoration: BoxDecoration(
                color: isSelected ? green : const Color(0xFF475569),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeroCardItem(Map<String, dynamic> banner) {
    final isNetwork = banner['isNetwork'] == true ||
        banner['image'].toString().startsWith('http://') ||
        banner['image'].toString().startsWith('https://');

    return GestureDetector(
      onTap: () {
        final tabIndex = banner['tabIndex'] as int;
        widget.onTabSelected?.call(tabIndex);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF334155), width: 1.2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Positioned.fill(
                child: isNetwork
                    ? Image.network(
                        banner['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFF161C26)),
                      )
                    : Image.asset(
                        banner['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFF161C26)),
                      ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(14.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      (banner['tag'] as String).toUpperCase(),
                      style: TextStyle(
                        color: green,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2.sp,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                banner['title'] as String,
                                style: TextStyle(
                                  color: const Color(0xFFF8FAFC),
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                ),
                              ),
                              SizedBox(height: 4.sp),
                              Text(
                                banner['subtitle'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFFF1F5F9),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.sp),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 13.sp, vertical: 8.sp),
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            banner['cta'] as String,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 3. Asymmetric Core Actions (FOR YOU Section with 16.sp Heading & Extra Large Text)
  Widget _buildAsymmetricCoreActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-heading: FOR YOU (Extra Large 16.sp Font Size)
          Text(
            'FOR YOU',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2.sp,
              shadows: const [
                Shadow(color: Colors.black, blurRadius: 4),
              ],
            ),
          ),
          SizedBox(height: 3.sp),
          Text(
            'Explore options & club features',
            style: TextStyle(
              color: const Color(0xFFCBD5E1),
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.sp),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT COLUMN: Tall "TRAIN" Card (Dumbbell icon)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () => widget.onTabSelected?.call(2),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161C26),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: const Color(0xFF334155), width: 1.2),
                    ),
                    padding: EdgeInsets.all(12.sp),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top Badge Tag
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 9.sp, vertical: 3.5.sp),
                          decoration: BoxDecoration(
                            color: green.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: green.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'TRAIN',
                            style: TextStyle(
                              color: green,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        // Middle 3D Dumbbell Icon & Title
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/images/3d_train_dumbbell.png',
                              width: 38.sp,
                              height: 38.sp,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: 4.sp),
                            Text(
                              'TRAIN',
                              style: TextStyle(
                                color: const Color(0xFFF8FAFC),
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5.sp,
                              ),
                            ),
                            SizedBox(height: 2.sp),
                            Text(
                              'Gyms & Workouts',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        // Bottom CTA Pill
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 9.sp, vertical: 4.sp),
                          decoration: BoxDecoration(
                            color: green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'EXPLORE',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(width: 2.sp),
                              Icon(Icons.arrow_forward_rounded,
                                  color: Colors.black, size: 10.sp),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10.sp),

              // RIGHT COLUMN: Stack of 2 Cards ("COMPETE" Medal Top, "SHOP" Cart Bottom)
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Top Card: COMPETE (Medal Icon)
                    GestureDetector(
                      onTap: () => widget.onTabSelected?.call(3),
                      child: Container(
                        height: 95,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161C26),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFF334155), width: 1.2),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.sp, vertical: 8.sp),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/3d_compete_medal.png',
                              width: 30.sp,
                              height: 30.sp,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 8.sp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'COMPETE',
                                    style: TextStyle(
                                      color: const Color(0xFFF8FAFC),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 2.sp),
                                  Text(
                                    'Events & Prizes',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 10.sp),

                    // Bottom Card: SHOP (Shopping Cart Icon)
                    GestureDetector(
                      onTap: () => widget.onTabSelected?.call(1),
                      child: Container(
                        height: 95,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161C26),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                              color: const Color(0xFF334155), width: 1.2),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.sp, vertical: 8.sp),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/3d_shop_cart.png',
                              width: 30.sp,
                              height: 30.sp,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: 8.sp),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'SHOP',
                                    style: TextStyle(
                                      color: const Color(0xFFF8FAFC),
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 2.sp),
                                  Text(
                                    'Apparel & Gear',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.5.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 4. Active Workout Card with 16.sp Heading & Extra Large Subtitles (STRICTLY CONDITIONAL)
  Widget _buildActiveWorkoutCard(WorkoutLogModel workoutLog) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONTINUE YOUR WORKOUT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2.sp,
                  shadows: const [
                    Shadow(color: Colors.black, blurRadius: 4),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.onTabSelected?.call(2),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.sp, vertical: 4.5.sp),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161C26),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: green.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: green,
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(width: 2.sp),
                      Icon(Icons.arrow_forward_rounded,
                          color: green, size: 11.5.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.sp),
          GestureDetector(
            onTap: () => widget.onTabSelected?.call(2),
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFF334155), width: 1.2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        "assets/images/challenge.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.90),
                              Colors.black.withValues(alpha: 0.25),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.sp),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workoutLog.exerciseName.isNotEmpty
                                      ? workoutLog.exerciseName
                                      : 'Active Training Session',
                                  style: TextStyle(
                                    color: const Color(0xFFF8FAFC),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 3.sp),
                                Text(
                                  '${workoutLog.sets} Sets · ${workoutLog.reps} Reps · ${workoutLog.weight} kg',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 6.sp),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: 0.5,
                                    minHeight: 5,
                                    backgroundColor:
                                        green.withValues(alpha: 0.25),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.sp),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.sp, vertical: 7.sp),
                            decoration: BoxDecoration(
                              color: green,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Text(
                              'CONTINUE →',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Near You Discovery Section with 16.sp Heading & Extra Large Subtitles (STRICTLY CONDITIONAL)
  Widget _buildNearYouDiscoverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NEAR YOU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2.sp,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onTabSelected?.call(3),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.sp, vertical: 4.5.sp),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161C26),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: green.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Explore All',
                            style: TextStyle(
                              color: green,
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 2.sp),
                          Icon(Icons.arrow_forward_rounded,
                              color: green, size: 11.5.sp),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.sp),
              Text(
                'Events & expeditions in your area',
                style: TextStyle(
                  color: const Color(0xFFCBD5E1),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.sp),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.sp),
            itemCount: _backendCompetitions.length,
            itemBuilder: (context, index) {
              final comp = _backendCompetitions[index];
              final hasImg = comp.image.isNotEmpty;
              final imgUrl = hasImg ? comp.image.first : '';

              return GestureDetector(
                onTap: () => widget.onTabSelected?.call(3),
                child: Container(
                  width: 250,
                  margin: EdgeInsets.only(right: 12.sp),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFF334155), width: 1.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: hasImg
                              ? Image.network(
                                  imgUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                      'assets/images/spiti.jpg',
                                      fit: BoxFit.cover),
                                )
                              : Image.asset('assets/images/spiti.jpg',
                                  fit: BoxFit.cover),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.90),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10.sp,
                          left: 10.sp,
                          right: 10.sp,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      comp.name.isNotEmpty
                                          ? comp.name
                                          : 'ORCA Event',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFFF8FAFC),
                                        fontSize: 14.5.sp,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 2.sp),
                                    Text(
                                      comp.place.isNotEmpty
                                          ? '${comp.place} · Nearby'
                                          : 'Sunday · 7:00 AM',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 9.5.sp, vertical: 5.sp),
                                decoration: BoxDecoration(
                                  color: green,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'VIEW EVENT →',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
