import 'package:dating/utils/textStyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';

class AppTextField extends StatefulWidget {
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? suffixIcon; // New parameter for suffix icon
  final IconData? prefixIcon;
  final TextEditingController inputcontroller; // New parameter for suffix icon

  const AppTextField({
    super.key,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon, // Optional suffix icon
    this.prefixIcon,
    required this.inputcontroller, // Optional suffix icon
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Neumorphic(
      style: NeumorphicStyle(
        shape: NeumorphicShape.flat,
        boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(20)),
        depth: -5,
        intensity: 1,
        surfaceIntensity: 0.5,
        lightSource: LightSource.topLeft,
      ),
      drawSurfaceAboveChild: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 55,
          maxHeight: 150, // Adjust the maxHeight as needed
        ),
        child: Scrollbar(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            reverse: true,
            child: TextFormField(
              controller: widget.inputcontroller,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText ? _obscureText : false,
              // maxLines: null, // Allows the text field to expand vertically
              decoration: InputDecoration(
                prefixIcon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon) // Display prefix icon if provided
                    : null,
                suffixIcon: widget.obscureText
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                          size: 20,
                        ),
                      )
                    : widget.suffixIcon != null
                        ? IconButton(
                            onPressed: () {
                              // Perform action for custom suffix icon
                            },
                            icon: Icon(widget.suffixIcon),
                          )
                        : null,
                hintText: widget.hintText,
                hintStyle: AppTextStyles().secondaryStyle,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
