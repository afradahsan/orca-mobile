import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:neopop/neopop.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/core/utils/read_more.dart';
import 'package:orca/features/community/presentation/book_now.dart';
import 'package:sizer/sizer.dart';

class CustomDrawerController {
  AnimationController? _animationController;
  bool _isInitialized = false;

  void attach(AnimationController controller) {
    _animationController = controller;
    _isInitialized = true;
  }

  bool get isOpen => _animationController?.value == 1.0;

  void open() {
    if (_isInitialized) {
      _animationController?.forward();
    }
  }

  void close() {
    if (_isInitialized) {
      _animationController?.reverse();
    }
  }

  void openToMin() => _animationController?.animateTo(0.5);

  void toggle() {
    if (_isInitialized) {
      if (isOpen) {
        close();
      } else {
        open();
      }
    }
  }

  void dispose() {
    _animationController = null;
    _isInitialized = false;
  }
}

Widget buildTrekDrawerContent({required String title, required String imagePath, required BuildContext context, required String location, required String duration}) {
  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.sp),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 60.sp,
                  ),
                ),
                sizedten(context),
                Text(
                  title,
                  style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 20.sp),
                ),
                sizedten(context),
                Container(
                    // margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
                    padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
                    decoration: BoxDecoration(
                      color: white.withAlpha(15),
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time_rounded, size: 20.sp, color: whitet150),
                            sizedwfive(context),
                            Text(
                              duration,
                              style: TextStyle(decoration: TextDecoration.none, fontSize: 18.sp, fontFamily: GoogleFonts.poppins().fontFamily, color: white),
                            ),
                            sizedwten(context),
                            Container(
                              height: 20.sp,
                              width: 5.sp,
                              decoration: BoxDecoration(
                                color: white.withAlpha(100),
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                            ),
                            sizedwten(context),
                            Icon(Icons.tsunami, size: 20.sp, color: whitet150),
                            sizedwfive(context),
                            Text(
                              duration,
                              style: TextStyle(decoration: TextDecoration.none, fontSize: 18.sp, color: white, fontFamily: GoogleFonts.poppins().fontFamily),
                            )
                          ],
                        ),
                        sizedten(context),
                        Container(
                          height: 5.sp,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: white.withAlpha(100),
                            borderRadius: BorderRadius.circular(12.sp),
                          ),
                        ),
                        sizedten(context),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 20.sp,
                              color: whitet150,
                            ),
                            sizedwfive(context),
                            Text(location, style: TextStyle(color: white, fontSize: 18.sp, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily))
                          ],
                        ),
                      ],
                    )),
                sizedtwenty(context),
                ReadMore(
                  text:
                      'Sar Pass Trek has some of the most stunning views in the Indian Himalayas, from lush meadows to snow-covered peaks. The trail takes you through an impressive mix of landscapes, dense forests, alpine meadows, rocky terrain, and snow-covered paths',
                  style: TextStyle(
                    color: white,
                    fontSize: 15.sp,
                    decoration: TextDecoration.none,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    letterSpacing: 4.sp,
                  ),
                ),
                sizedtwenty(context),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _infoBlock(context, Icons.terrain, 'Altitude', '13,800 ft'),
                        sizedwfive(context),
                        _infoBlock(context, Icons.cloud, 'Temperature', '0–15°C'),
                      ],
                    ),
                    sizedten(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _infoBlock(context, Icons.hotel, 'Stay Type', 'Tent'),
                        sizedwfive(context),
                        _infoBlock(context, Icons.calendar_month, 'Best Season', 'May–June'),
                      ],
                    ),
                    sizedten(context),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [_infoBlock(context, Icons.group, 'Group Size', '15 Max'), sizedwfive(context), _infoBlock(context, Icons.fitness_center, 'Fitness', 'Moderate')],
                    )
                  ],
                ),
                // GridView.count(
                //   crossAxisCount: 2,
                //   childAspectRatio: 3.5,
                //   shrinkWrap: true,
                //   physics: NeverScrollableScrollPhysics(),
                //   crossAxisSpacing: 10.sp,
                //   mainAxisSpacing: 10.sp,
                //   children: [
                //     ,
                //   ],
                // ),
                sizedtwenty(context),
                Text(
                  'What’s Included',
                  style: TextStyle(
                    color: green,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    decoration: TextDecoration.none,
                  ),
                ),
                sizedten(context),
                _bulletPoint(context, "Accommodation in tents or homestays", true),
                _bulletPoint(context, "Veg meals – breakfast, lunch, dinner", true),
                _bulletPoint(context, "Experienced trek guide", true),
                _bulletPoint(context, "Permits and first-aid support", true),
                sizedtwenty(context),
                Text(
                  'What’s Not Included',
                  style: TextStyle(
                    color: green,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    decoration: TextDecoration.none,
                  ),
                ),
                sizedten(context),
                _bulletPoint(context, "Personal expenses or insurance", false),
                _bulletPoint(context, "Gear rental (sleeping bag, trekking shoes)", false),
                _bulletPoint(context, "Transport to base camp", false),

                sizedtwenty(context),

                // // CTA Button
                // Center(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       // Your apply logic here
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: green,
                //       foregroundColor: Colors.black,
                //       padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 12.sp),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(12.sp),
                //       ),
                //     ),
                //     child: Text(
                //       "Apply Now",
                //       style: TextStyle(
                //         fontSize: 14.sp,
                //         fontWeight: FontWeight.bold,
                //         fontFamily: GoogleFonts.poppins().fontFamily,
                //         decoration: TextDecoration.none,
                //       ),
                //     ),
                //   ),
                // ),`
              ],
            ),
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        decoration: BoxDecoration(color: Color.fromARGB(255, 61, 81, 55)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Starts from',
                  style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 13.sp, letterSpacing: 3.sp),
                ),
                Text(
                  '₹3999',
                  style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 20.sp, fontWeight: FontWeight.w800, letterSpacing: 3.sp),
                )
              ],
            ),
            NeoPopButton(
                color: darkgreen,
                bottomShadowColor: green,
                rightShadowColor: green,
                onTapUp: () {},
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
                  child: Text(
                    'Apply Now',
                    style: TextStyle(color: green, fontSize: 16.sp, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily),
                  ),
                )),
          ],
        ),
      )
    ],
  );
}

Widget buildCompetitionsDrawerContent(
    {required String title, required String imagePath, required BuildContext context, required String location, required String time, required DateTime date, required String rules}) {
  String formattedDate = DateFormat('EEE, dd MMMM').format(date);
  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(12.sp),
                //   child: Image.asset(
                //     imagePath,
                //     fit: BoxFit.cover,
                //     width: double.infinity,
                //     height: 60.sp,
                //   ),
                // ),
                // sizedten(context),
                Text(
                  '🏏 $title',
                  style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 20.sp),
                ),
                sizedten(context),
                Container(
                    // margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
                    padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
                    decoration: BoxDecoration(
                      color: white.withAlpha(15),
                      borderRadius: BorderRadius.circular(12.sp),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 16.sp, color: whitet150),
                            sizedwfive(context),
                            Text(
                              formattedDate,
                              style: TextStyle(decoration: TextDecoration.none, fontSize: 16.sp, fontFamily: GoogleFonts.poppins().fontFamily, color: white),
                            ),
                            sizedwfive(context),
                            Container(
                              height: 15.sp,
                              width: 5.sp,
                              decoration: BoxDecoration(
                                color: white.withAlpha(100),
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                            ),
                            sizedwfive(context),
                            Text(
                              '$time onwards',
                              style: TextStyle(decoration: TextDecoration.none, fontSize: 16.sp, color: white, fontFamily: GoogleFonts.poppins().fontFamily),
                            )
                          ],
                        ),
                        sizedten(context),
                        Container(
                          height: 3.sp,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: white.withAlpha(100),
                            borderRadius: BorderRadius.circular(12.sp),
                          ),
                        ),
                        sizedten(context),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 18.sp,
                              color: whitet150,
                            ),
                            sizedwfive(context),
                            Text(location, style: TextStyle(color: white, fontSize: 16.sp, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily))
                          ],
                        ),
                      ],
                    )),
                sizedtwenty(context),
                Text('Rules', style: TextStyle(color: green, fontSize: 22.sp, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily)),
                Text(
                  rules,
                  style: TextStyle(
                    color: white,
                    fontSize: 15.sp,
                    decoration: TextDecoration.none,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    letterSpacing: 4.sp,
                  ),
                ),
                sizedtwenty(context),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    matchInfo(context, Icons.sports_cricket_rounded, 'Match Type', 'Limited Overs'),
                    sizedten(context),
                    matchInfo(context, Icons.timelapse_rounded, 'No. of Overs', '12 Overs'),
                    sizedten(context),
                    matchInfo(context, Icons.sports_baseball_rounded, 'Ball Type', 'Tennis'),
                    sizedten(context),
                    matchInfo(context, Icons.person, 'Team Size', '11'),
                  ],
                ),
                sizedtwenty(context),
              ],
            ),
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        decoration: BoxDecoration(color: Color.fromARGB(255, 61, 81, 55)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ground Fee (Per Team)',
                  style: TextStyle(color: white, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 14.sp, letterSpacing: 3.sp),
                ),
                Text(
                  '₹1200',
                  style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 20.sp, fontWeight: FontWeight.w800, letterSpacing: 3.sp),
                )
              ],
            ),
            NeoPopButton(
                color: darkgreen,
                bottomShadowColor: green,
                rightShadowColor: green,
                onTapUp: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const BookNow();
                    },
                  ));
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
                  child: Text(
                    'Register Now',
                    style: TextStyle(color: green, fontSize: 16.sp, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily),
                  ),
                )),
          ],
        ),
      )
    ],
  );
}

Widget buildBikeRideDrawerContent({
  required String title,
  required BuildContext context,
  required String startLocation,
  required String endLocation,
  required DateTime date,
  required String time,
  required String distance,
  required String difficulty,
  required String rideType,
}) {
  String formattedDate = DateFormat('EEE, dd MMMM').format(date);

  return Column(
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title',
                  style: TextStyle(
                    color: green,
                    decoration: TextDecoration.none,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 20.sp,
                  ),
                ),
                sizedten(context),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
                  decoration: BoxDecoration(
                    color: white.withAlpha(15),
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 16.sp, color: whitet150),
                          sizedwfive(context),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: white,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          sizedwfive(context),
                          Container(
                            height: 15.sp,
                            width: 5.sp,
                            decoration: BoxDecoration(
                              color: white.withAlpha(100),
                              borderRadius: BorderRadius.circular(12.sp),
                            ),
                          ),
                          sizedwfive(context),
                          Text(
                            '$time onwards',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: white,
                              fontFamily: GoogleFonts.poppins().fontFamily,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      sizedten(context),
                      Container(
                        height: 3.sp,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: white.withAlpha(100),
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                      ),
                      sizedten(context),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 18.sp, color: whitet150),
                          sizedwfive(context),
                          Expanded(
                            child: Text(
                              '$startLocation → $endLocation',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: white,
                                fontFamily: GoogleFonts.poppins().fontFamily,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                sizedtwenty(context),
                Text(
                  'Quick Info',
                  style: TextStyle(
                    color: green,
                    fontSize: 22.sp,
                    decoration: TextDecoration.none,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
                sizedten(context),
                Column(
                  children: [
                    matchInfo(context, Icons.directions_bike, 'Ride Type', rideType),
                    sizedten(context),
                    matchInfo(context, Icons.social_distance, 'Distance', distance),
                    sizedten(context),
                    matchInfo(context, Icons.whatshot, 'Difficulty', difficulty),
                  ],
                ),
                sizedtwenty(context),
              ],
            ),
          ),
        ),
      ),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
        decoration: BoxDecoration(color: const Color.fromARGB(255, 61, 81, 55)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Participation Fee',
                  style: TextStyle(
                    color: white,
                    decoration: TextDecoration.none,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 14.sp,
                    letterSpacing: 3.sp,
                  ),
                ),
                Text(
                  '₹300',
                  style: TextStyle(
                    color: green,
                    decoration: TextDecoration.none,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.sp,
                  ),
                ),
              ],
            ),
            NeoPopButton(
              color: darkgreen,
              bottomShadowColor: green,
              rightShadowColor: green,
              onTapUp: () {},
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
                child: Text(
                  'Register Now',
                  style: TextStyle(
                    color: green,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    ],
  );
}

Widget matchInfo(BuildContext context, IconData icon, String title, String value) {
  return Row(
    children: [
      Icon(icon, size: 20.sp, color: whitet100),
      sizedwfive(context),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: green, fontSize: 14.sp, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, letterSpacing: 4.sp)),
          sizedfive(context),
          Text(value, style: TextStyle(color: white, fontSize: 16.sp, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, letterSpacing: 4.sp))
        ],
      )
    ],
  );
}

Widget _infoBlock(BuildContext context, IconData icon, String title, String value) {
  return Container(
    height: 30.sp,
    width: 53.sp,
    padding: EdgeInsets.symmetric(horizontal: 21.sp, vertical: 8.sp),
    decoration: BoxDecoration(
      color: white.withAlpha(15),
      borderRadius: BorderRadius.circular(8.sp),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(icon, color: green, size: 20.sp),
        sizedwfive(context),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: white,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  decoration: TextDecoration.none,
                )),
            Text(value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: green,
                  fontFamily: GoogleFonts.poppins().fontFamily,
                  decoration: TextDecoration.none,
                )),
          ],
        ),
      ],
    ),
  );
}

Widget _bulletPoint(BuildContext context, String text, bool included) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4.sp),
    child: Row(
      children: [
        included ? Image.asset('assets/icons/checked.png') : Image.asset('assets/icons/close.png'),
        sizedwfive(context),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            color: white,
            fontFamily: GoogleFonts.poppins().fontFamily,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    ),
  );
}

class CustomDrawer extends StatefulWidget {
  final Widget mainContent;
  final Widget drawerContent;
  final double minHeight;
  final double maxHeight;
  final Duration animationDuration;
  final Color backgroundColor;
  final Color barrierColor;
  final CustomDrawerController? controller;

  const CustomDrawer({
    super.key,
    required this.mainContent,
    required this.drawerContent,
    this.controller,
    this.minHeight = 0.0,
    this.maxHeight = 0.90,
    this.animationDuration = const Duration(milliseconds: 300), // Faster animation
    this.backgroundColor = darkgreen,
    this.barrierColor = Colors.black54,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _drawerAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  bool _isDragging = false;
  double _dragStartPoint = 0.0;
  double _dragStartValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    widget.controller?.attach(_controller);

    // Enhanced easing curve for smoother animation
    const Curve curve = Curves.easeInOutCubic;

    _drawerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    // Increased scale effect for better depth perception
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.85, // More pronounced scale effect
    ).animate(CurvedAnimation(parent: _controller, curve: curve));

    // Enhanced slide effect
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 24.0, // More pronounced slide
    ).animate(CurvedAnimation(parent: _controller, curve: curve));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate maxDrawerHeight based on parent width
      final maxDrawerHeight = constraints.maxHeight * widget.maxHeight;

      return Stack(
        children: [
          // Main content with enhanced scale, slide and border radius animations
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, -_slideAnimation.value),
                  child: ClipRRect(
                    // Animate border radius based on drawer animation
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(_drawerAnimation.value * 16.0),
                    ),
                    child: widget.mainContent,
                  ),
                ),
              );
            },
          ),

          // Enhanced barrier with fade animation
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Visibility(
                visible: _controller.value > 0,
                child: GestureDetector(
                  onTap: () => _controller.reverse(),
                  child: Container(
                    color: widget.barrierColor.withOpacity(_controller.value * 0.7),
                  ),
                ),
              );
            },
          ),

          // Enhanced drawer with improved handle and shadow
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: maxDrawerHeight,
                child: Transform.translate(
                  offset: Offset(0.0, maxDrawerHeight * (1 - _drawerAnimation.value)),
                  child: GestureDetector(
                    onVerticalDragStart: _handleDragStart,
                    onVerticalDragUpdate: (details) => _handleDragUpdate(details, maxDrawerHeight),
                    onVerticalDragEnd: _handleDragEnd,
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.backgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16), // Increased radius
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Enhanced drag handle
                          Container(
                            height: 24, // Reduced height
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          // Drawer content
                          Expanded(
                            child: widget.drawerContent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  // Drag handlers remain the same as in your original code
  void _handleDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartPoint = details.globalPosition.dy;
    _dragStartValue = _controller.value;
  }

  void _handleDragUpdate(DragUpdateDetails details, double maxDrawerHeight) {
    if (!_isDragging) return;

    final dragDistance = _dragStartPoint - details.globalPosition.dy;
    // Use maxDrawerHeight instead of screen height for calculations
    final newValue = (_dragStartValue + dragDistance / maxDrawerHeight).clamp(0.0, 1.0);
    _controller.value = newValue;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;

    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;

    if (velocity > 0) {
      // Dragging down
      _controller.reverse();
    } else if (velocity < 0) {
      // Dragging up
      _controller.forward();
    } else {
      // No velocity - snap to nearest end
      if (_controller.value > 0.5) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    _controller.dispose();
    super.dispose();
  }
}
