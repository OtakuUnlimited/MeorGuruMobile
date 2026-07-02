import 'dart:io';

import 'package:flutter/material.dart';
import '../../../constants.dart';

class ProfileImageSection extends StatelessWidget {
  final String? imageUrl;
  final File? selectedImage;
  final bool editable;
  final VoidCallback? onTap;
  final String firstName;
  final String lastName;

   const ProfileImageSection({
    super.key,
    this.imageUrl,
    this.selectedImage,
    this.editable = false,
    this.onTap,
    required this.firstName,
    required this.lastName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: editable ? onTap : null,
          child: Stack(
            children: [

            CircleAvatar(
              radius: 55,

              backgroundImage:
                  selectedImage != null
                      ? FileImage(selectedImage!)
                      : imageUrl != null &&
                              imageUrl!.isNotEmpty
                          ? NetworkImage(imageUrl!)
                          : null,

              child: selectedImage == null &&
                      (imageUrl == null || imageUrl!.isEmpty)
                  ? Text(
                      "${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}",
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),

            if (editable)
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.red,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),

        const SizedBox(height: 12),

        Text(
          "$firstName $lastName",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}