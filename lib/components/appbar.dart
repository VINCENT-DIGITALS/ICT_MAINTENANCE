import 'package:flutter/material.dart';

class CurvedEdgesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final Widget? child; // Allows customization per page
  final bool showFooter; // Controls whether to show the "Developed by..." text
  final Color backgroundColor;

  const CurvedEdgesAppBar({
    super.key,
    required this.height,
    this.child,
    this.showFooter = false, // Default: false, can be enabled per page
    this.backgroundColor = const Color.fromRGBO(20, 33, 61, 1),
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: CurvedEdgesClipper(),
      child: Container(
        height: height,
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (child != null) child!, // Display content if provided

            // "Developed by..." at the lowest part, but only if enabled
            if (showFooter)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: const Text(
                  'Developed by Information Systems Division',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
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
    Path path = Path();
    path.lineTo(0, size.height - 30);

    // Left curve
    path.quadraticBezierTo(size.width * 0.05, size.height, size.width * 0.2, size.height);

    // Straight middle
    path.lineTo(size.width * 0.8, size.height);

    // Right curve
    path.quadraticBezierTo(size.width * 0.95, size.height, size.width, size.height - 30);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
