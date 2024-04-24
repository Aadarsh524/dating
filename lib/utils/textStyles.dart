import 'package:dating/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  TextStyle authMainStyle = GoogleFonts.getFont(
    "Poppins",
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  TextStyle authLabelStyle = GoogleFonts.getFont(
    "Poppins",
    color: AppColors.black,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  TextStyle secondaryStyle = GoogleFonts.getFont(
    "Poppins",
    color: AppColors.secondaryColor,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  TextStyle primaryStyle = GoogleFonts.getFont(
    "Poppins",
    color: AppColors.black,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
}
