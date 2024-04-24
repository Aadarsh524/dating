import 'package:dating/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Button extends StatefulWidget {
  final String text;

  final VoidCallback onPressed;
  final String? imagePath;

  const Button({
    Key? key,
    required this.text,
    this.imagePath,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<Button> createState() => ButtonState();
}

class ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    return NeumorphicButton(
      onPressed: () {
        widget.onPressed();
      },
      style: NeumorphicStyle(
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        depth: 5,
        intensity: 0.75,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.text,
            style: GoogleFonts.poppins(
              color: AppColors.black,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
// for button
          if (widget.imagePath != null) // Display image if provided
            Image.asset(
              widget.imagePath!,
              height: 20,
            ), // Load image from asset
          if (widget.imagePath != null) // Add some space if image is provided
            SizedBox(width: 0),
        ],
      ),
    );
  }
}

class ButtonWithLabel extends StatefulWidget {
  final String? text;
  final String? labelText;

  final VoidCallback onPressed;
  final Widget? icon;

  const ButtonWithLabel({
    Key? key,
    required this.text,
    required this.labelText,
    this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<ButtonWithLabel> createState() => ButtonWithLabelState();
}

class ButtonWithLabelState extends State<ButtonWithLabel> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NeumorphicButton(
          margin: EdgeInsets.only(top: 10),
          onPressed: () {
            widget.onPressed();
          },
          style: NeumorphicStyle(
            boxShape: NeumorphicBoxShape.circle(),
            depth: 5,
            intensity: 0.75,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.text != null)
                Text(
                  widget.text!,
                  style: GoogleFonts.poppins(
                    color: AppColors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (widget.text != null) SizedBox(width: 8),
              // for button
              if (widget.icon != null) // Display icon if provided
                widget.icon!,
              // Add some space if image is provided
              SizedBox(width: 0),
            ],
          ),
        ),
        if (widget.labelText != null)
          SizedBox(
            height: 5,
          ),
        // Display icon if provided
        if (widget.labelText != null)
          Text(
            widget.labelText!,
            style: GoogleFonts.poppins(
              color: AppColors.black,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }
}
