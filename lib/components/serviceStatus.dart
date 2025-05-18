import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:servicetracker_app/components/imageViewer.dart';

Widget statusItem(BuildContext context, String time, String status,
    {String? imagePath}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: const TextStyle(
              fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status,
                style: const TextStyle(fontSize: 14),
              ),
              if (imagePath != null && imagePath.isNotEmpty)
                GestureDetector(
                  onTap: () => showImagePreview(context, imagePath),
                  child: Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: buildImage(imagePath),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildImage(String imagePath) {
  // Check if the path is a network image (starts with http)
  if (imagePath.startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
  // Handle server storage paths that don't have the full URL (both formats)
  else if (imagePath.startsWith('/storage/') ||
      imagePath.startsWith('storage/') ||
      imagePath.startsWith('/documentation/')) {
    // Normalize the path to always start with a slash if it doesn't
    String normalizedPath =
        imagePath.startsWith('/') ? imagePath : '/$imagePath';

    // Base URL of your application
    const String baseUrl = 'http://192.168.43.128/ServiceTrackerGithub/public';

    // Create the full URL
    String fullPath = '$baseUrl$normalizedPath';

    print('Image URL: $fullPath'); // Keep for debugging

    return CachedNetworkImage(
      imageUrl: fullPath,
      fit: BoxFit.cover,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
  // Handle local files
  else {
    return Image.file(
      File(imagePath),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
    );
  }
}

// Similarly, update the showImagePreview function to handle server paths
void showImagePreview(BuildContext context, String imagePath) {
  String displayPath = imagePath;

  // If it's a server path without full URL, add the base URL
  if (imagePath.startsWith('/storage/') ||
      imagePath.startsWith('storage/') ||
      imagePath.startsWith('/documentation/')) {
    // Normalize the path to always start with a slash if it doesn't
    String normalizedPath =
        imagePath.startsWith('/') ? imagePath : '/$imagePath';

    // Base URL of your application
    const String baseUrl = 'http://192.168.43.128/ServiceTrackerGithub/public';

    // Create the full URL
    displayPath = '$baseUrl$normalizedPath';

    print('Preview URL: $displayPath'); // Keep for debugging
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          children: [
            // Image with proper handling of path types
            InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4,
              child: imagePath.startsWith('http') ||
                      imagePath.startsWith('/storage/') ||
                      imagePath.startsWith('storage/') ||
                      imagePath.startsWith('/documentation/')
                  ? CachedNetworkImage(
                      imageUrl: displayPath,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    )
                  : Image.file(
                      File(imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
            ),

            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}
