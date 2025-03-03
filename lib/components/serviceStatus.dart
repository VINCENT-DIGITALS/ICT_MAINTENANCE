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


