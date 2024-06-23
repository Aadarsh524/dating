import 'package:dating/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavigationRailDestination extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomNavigationRailDestination({
    Key? key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
        child: Container(
          decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              borderRadius:
                  isSelected ? BorderRadius.circular(20) : BorderRadius.zero),
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 50.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(isSelected ? selectedIcon : icon,
                  color: isSelected ? AppColors.blue : Colors.white),
              const SizedBox(width: 20),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: isSelected ? AppColors.blue : Colors.white,
                  fontSize: 16.0,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
