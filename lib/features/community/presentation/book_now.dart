import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:sizer/sizer.dart';

class BookNow extends StatefulWidget {
  const BookNow({super.key});

  @override
  State<BookNow> createState() => _BookNowState();
}

class _BookNowState extends State<BookNow> {
  var preferredSlot = ['Morning', 'Afternoon', 'Evening'];

  final TextEditingController teamNameCtrlr = TextEditingController();
  final TextEditingController captainNameCtrlr = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    teamNameCtrlr.dispose();
    captainNameCtrlr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var preferredSlotVal = preferredSlot[0];
    return Scaffold(
      appBar: AppBar(
        // titleSpacing: 4.sp,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Register Your Team',
          style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 20.sp, fontWeight: FontWeight.w800, letterSpacing: 3.sp),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Team Name',
                    style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 16.sp, fontWeight: FontWeight.w800, letterSpacing: 3.sp),
                  ),
                  sizedten(context),
                  textFormField(controller: teamNameCtrlr, labelText: '', hint: '', inputType: TextInputType.name),
                  sizedten(context),
                  Text(
                    'Captain Name',
                    style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 16.sp, fontWeight: FontWeight.w800, letterSpacing: 3.sp),
                  ),
                  sizedten(context),
                  textFormField(controller: captainNameCtrlr, labelText: '', hint: '', inputType: TextInputType.name),
                  sizedten(context),
                  Text(
                    'Phone No.',
                    style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 16.sp, fontWeight: FontWeight.w800, letterSpacing: 3.sp),
                  ),
                  sizedten(context),
                  textFormField(controller: captainNameCtrlr, labelText: '', hint: '', inputType: TextInputType.phone),
                  sizedten(context),
                  Text(
                    'Email ID',
                    style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 16.sp, fontWeight: FontWeight.w800, letterSpacing: 3.sp),
                  ),
                  sizedten(context),
                  textFormField(controller: captainNameCtrlr, labelText: '', hint: '', inputType: TextInputType.emailAddress),
                  sizedten(context),
                  Text(
                    'Preferred Slot',
                    style: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 16.sp, fontWeight: FontWeight.w800, letterSpacing: 3.sp),
                  ),
                  sizedten(context),
                  DropdownButtonFormField(
                    dropdownColor: darkgreen,
                    value: preferredSlotVal,
                    items: preferredSlot.map((String mode) {
                      return DropdownMenuItem(
                          value: mode,
                          child: Text(
                            mode,
                            style: TextStyle(fontSize: 16.sp, color: green),
                          ));
                    }).toList(),
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        preferredSlotVal = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                        constraints: BoxConstraints(maxWidth: 93.w, maxHeight: 7.h),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: white)),
                        disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: white)),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: green)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
                  ),
                  SizedBox(height: 60.sp),
                  Align(
                    alignment: Alignment.center,
                    child: NeoPopButton(
                        color: darkgreen,
                        bottomShadowColor: green,
                        rightShadowColor: green,
                        onTapUp: () {
                          // Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Proceed',
                                style: TextStyle(color: green, fontSize: 16.sp, fontWeight: FontWeight.bold, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily),
                              ),
                              sizedwfive(context),
                              Icon(Icons.arrow_right_alt, color: green)
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

TextFormField textFormField({required TextEditingController controller, required String labelText, required String hint, required TextInputType inputType, double? size}) {
  return TextFormField(
    controller: controller,
    style: TextStyle(color: green, fontSize: size ?? 15.sp),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'The feild cannot be empty.';
      }
      return null;
    },
    keyboardType: inputType,
    decoration: InputDecoration(
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: white)),
      disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: white)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: green)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
      labelText: labelText,
      labelStyle: TextStyle(color: green, fontSize: size ?? 12.sp),
      hintText: hint,
      hintStyle: TextStyle(color: green, decoration: TextDecoration.none, fontFamily: GoogleFonts.poppins().fontFamily, fontSize: 12.sp, fontWeight: FontWeight.w800, letterSpacing: 3.sp),
    ),
  );
}
