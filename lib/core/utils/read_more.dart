import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:sizer/sizer.dart';

class ReadMore extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ReadMore({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<ReadMore> createState() => _ReadMoreState();
}

class _ReadMoreState extends State<ReadMore> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: widget.style,
          maxLines: _isExpanded ? null : 3,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        sizedfive(context),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(
            _isExpanded ? "Read less" : "Read more...",
            style: TextStyle(
              color: Color(0xFF8b7a6b),
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
