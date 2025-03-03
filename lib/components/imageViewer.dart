import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget buildImage(String imagePath) {
  bool isNetworkImage = imagePath.startsWith('http');

  return ClipRRect(
    borderRadius: BorderRadius.circular(5),
    child: isNetworkImage
        ? CachedNetworkImage(
            imageUrl: imagePath,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
            fit: BoxFit.cover,
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image),
          ),
  );
}


void showImagePreview(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.7), // Darkens background slightly
    
    builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Dialog Container
              Dialog(
                backgroundColor:
                    Colors.white, // Fully transparent background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.85,
                    maxHeight: MediaQuery.of(context).size.height * 0.6,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: buildImage(imagePath), // Display the image
                  ),
                ),
              ),

              // Floating close button slightly below the modal
              Positioned(
                bottom: 30, // Pushes the button below the modal
                child: FloatingActionButton(
                  onPressed: () => Navigator.pop(context),
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 4,
                  mini: true, // Slightly smaller button
                  child: const Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
