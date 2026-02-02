import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:sizer/sizer.dart';
import '../data/competitions_model.dart';

class CompetitionDetailsPage extends StatelessWidget {
  final Competition competition;
  const CompetitionDetailsPage({super.key, required this.competition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeroSection()),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.sp, 20.sp, 20.sp, 20.sp),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(context),
                      SizedBox(height: 14.sp),
                      _buildEventCard(),
                      SizedBox(height: 14.sp),
                      _buildLocationCard(),
                      SizedBox(height: 24.sp),
                      _buildFeeCard(),
                      SizedBox(height: 28.sp),
                      _buildDescription(),
                      SizedBox(height: 100.sp),
                    ]),
                  ),
                ),
              ],
            ),
            _buildBackButton(),
            _buildRegisterButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    final imageUrl = competition.image.isNotEmpty == true ? competition.image.first : "https://via.placeholder.com/800x400/1a1a1a/ffffff?text=Competition";

    return Container(
      height: 45.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.sp),
          bottomRight: Radius.circular(28.sp),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.sp),
          bottomRight: Radius.circular(28.sp),
        ),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Color(0xFF1a1a1a),
            child: Icon(Icons.event_busy, size: 60.sp, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _shareCompetition(BuildContext context) async {
//   final shareText = '''
// 🏆 ${competition.name}

// 📅 Date: ${_formatDate(competition.date)}
// 🕒 Time: ${competition.time ?? 'TBD'}
// 📍 ${competition.place}, ${competition.state.isNotEmpty ? competition.state.first : 'Kerala'}
// 💰 Entry: ₹${competition.cost}
// ⏱️ Duration: ${competition.duration} days
// 🏷️ Type: ${competition.type.isNotEmpty ? competition.type.first : 'Individual'}

// ${competition.description?.isNotEmpty == true ? competition.description! : 'Join this exciting competition!'}

// #OrcaFitness #Competition
// ''';

//   // FIXED: Remove sharePositionOrigin - causes crashes
//   await SharePlus.instance.share(
//     ShareParams(text: shareText),
//   );
}


Widget _buildHeader(BuildContext context) {
    final category = competition.category.isNotEmpty ? competition.category.first : "General";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
              decoration: BoxDecoration(
                color: green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.sp),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_kabaddi, color: green, size: 16.sp),
                  SizedBox(width: 6.sp),
                  Text(category, style: TextStyle(color: green, fontSize: 12.sp, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () => _shareCompetition(context),
              icon: Icon(Icons.share_outlined, color: Colors.white54, size: 22.sp),
            ),
          ],
        ),
        SizedBox(height: 12.sp),
        Text(
          competition.name,
          style: TextStyle(
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
            fontSize: 24.sp,
            color: Colors.white,
            height: 1.1,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEventCard() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(20.sp),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.calendar_month, "Date", _formatDate(competition.date)),
          SizedBox(height: 16.sp),
          _buildInfoItem(Icons.access_time, "Time", competition.time ?? "TBD"),
          SizedBox(height: 16.sp),
          _buildInfoItem(Icons.timer, "Duration", "${competition.duration} days"),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    final state = competition.state.isNotEmpty ? competition.state.first : "Kerala";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: green, size: 20.sp),
            SizedBox(width: 8.sp),
            Text("Event Details", style: _sectionTitleStyle()),
          ],
        ),
        SizedBox(height: 16.sp),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(20.sp),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              // Location Group
              _buildLocationRow("Place", '${competition.place}, $state'),

              // Divider
              Container(height: 1, color: Colors.white.withOpacity(0.1), margin: EdgeInsets.symmetric(vertical: 16.sp)),

              // Competition Specs
              _buildLocationRow("Max Registrations", competition.maxRegistrations.toString()),
              SizedBox(height: 8.sp),
              _buildLocationRow("Type", competition.type.isNotEmpty ? competition.type.first : "Individual"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2a2a2a), Color(0xFF1a1a1a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.sp),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Entry Fee", style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
              Text(
                "₹${competition.cost}",
                style: TextStyle(
                  fontFamily: GoogleFonts.bebasNeue().fontFamily,
                  fontSize: 24.sp,
                  color: green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
            decoration: BoxDecoration(
              color: green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Icon(Icons.arrow_forward_ios, color: green, size: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text("About", style: _sectionTitleStyle()),
            Spacer(),
            Icon(Icons.info_outline, color: Colors.white54, size: 20.sp),
          ],
        ),
        SizedBox(height: 16.sp),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.sp),
          decoration: BoxDecoration(
            color: Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(20.sp),
          ),
          child: Text(
            competition.description ?? "No description available.",
            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14.sp, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 20.sp,
      left: 20.sp,
      child: Container(
        padding: EdgeInsets.all(12.sp),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
        ),
        child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18.sp),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Positioned(
      bottom: 15.sp,
      left: 20.sp,
      right: 20.sp,
      child: Container(
        height: 28.sp,
        decoration: BoxDecoration(
          color: green,
          borderRadius: BorderRadius.circular(28.sp),
          boxShadow: [
            BoxShadow(
              color: green.withOpacity(0.4),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15.sp),
            onTap: () => _showRegisterSnackBar(context),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Register Now",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 8.sp),
                  Icon(Icons.arrow_forward, size: 18.sp, color: Colors.black),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.sp),
          decoration: BoxDecoration(
            color: green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: green, size: 18.sp),
        ),
        SizedBox(width: 16.sp),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white54, fontSize: 13.sp)),
              SizedBox(height: 4.sp),
              Text(value, style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow(String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.sp),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.w500, fontSize: 13.sp)),
          Expanded(child: Text(value, style: TextStyle(color: Colors.white, fontSize: 14.sp))),
        ],
      ),
    );
  }

  TextStyle _sectionTitleStyle() => TextStyle(
        fontFamily: GoogleFonts.bebasNeue().fontFamily,
        fontSize: 20.sp,
        color: Colors.white,
        letterSpacing: 1,
      );

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";

  void _showRegisterSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.schedule, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text("Registration feature coming soon!")),
          ],
        ),
        backgroundColor: green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
