import 'dart:io';

import 'package:flutter/material.dart';

class GeminiChatBubble extends StatelessWidget {
  final String userName;
  final String timestamp;
  final String message;
  final String imageUrl;

  const GeminiChatBubble({
    super.key,
    required this.userName,
    required this.timestamp,
    required this.message,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Your CircleAvatar logic here
              // ...
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    timestamp,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          if (imageUrl.isNotEmpty)
            Image.file(
              File(imageUrl),
              width: 90,
              height: 90,
            ),
        ],
      ),
    );
  }
}
