import 'package:flutter/material.dart';

class CurvedEdgesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget? child; // Allows customization per page
  final bool showFooter; // Controls whether to show the "Developed by..." text
  final Color? backgroundColor; // Optional background color, can be null
  final String? backgroundImage; // Optional background image

  const CurvedEdgesAppBar({
    super.key,
    required this.height,
    this.child,
    this.showFooter = false, // Default: false, can be enabled per page
    this.backgroundColor, // Accept an optional background color
    this.backgroundImage, // Accept the background image URL or path
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurvedEdgesClipper(),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundImage == null
              ? (backgroundColor ?? Colors.transparent)
              : null,
          image: backgroundImage != null
              ? DecorationImage(
                  image: AssetImage(backgroundImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (child != null) child!,
            if (showFooter)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: const Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "Developed by: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Roboto",
                        ),
                      ),
                      TextSpan(
                        text: "Information Systems Division",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          fontFamily: "Roboto",
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class CurvedEdgesClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double cornerRadius = 40.0; // Radius for bottom corners

    Path path = Path();
    path.lineTo(0, size.height - cornerRadius);

    // Bottom left rounded corner
    path.quadraticBezierTo(0, size.height, cornerRadius, size.height);

    // Straight middle
    path.lineTo(size.width - cornerRadius, size.height);

    // Bottom right rounded corner
    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height - cornerRadius);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
