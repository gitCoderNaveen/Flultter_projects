import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../controller/profile_controller.dart';

class ProfileImagePicker extends StatelessWidget {
  final ProfileController controller;

  const ProfileImagePicker({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            //------------------------------------------
            // PROFILE IMAGE
            //------------------------------------------

            // Stack(
            //   alignment: Alignment.bottomRight,
            //   children: [

            //     // CircleAvatar(
            //     //   radius: 65,
            //     //   backgroundColor: Colors.grey.shade200,
            //     //   child: ClipOval(
            //     //     child: SizedBox(
            //     //       width: 130,
            //     //       height: 130,
            //     //       child: _buildImage(),
            //     //     ),
            //     //   ),
            //     // ),

            //     FloatingActionButton.small(
            //       heroTag: "profile_image",
            //       backgroundColor: Theme.of(context).primaryColor,
            //       onPressed: () async {
            //         await controller.pickProfileImage();
            //       },
            //       child: const Icon(Icons.camera_alt),
            //     ),
            //   ],
            // ),

            const SizedBox(height: 20),

            Text(
              controller.personNameController.text.isEmpty
                  ? "Your Name"
                  : controller.personNameController.text,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              controller.mobileController.text,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 18),

            // SizedBox(
            //   width: double.infinity,
            //   child: OutlinedButton.icon(
            //     icon: const Icon(Icons.photo),
            //     label: const Text("Change Photo"),
            //     onPressed: () async {
            //       await controller.pickProfileImage();
            //     },
            //   ),
            // ),

            if (controller.profileImageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: TextButton.icon(
                  onPressed: () {
                    controller.removeProfileImage();
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ),
                  label: const Text(
                    "Remove Image",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    //------------------------------------------
    // LOCAL IMAGE
    //------------------------------------------

    if (controller.profileImageFile != null) {
      return Image.file(
        File(controller.profileImageFile!.path),
        fit: BoxFit.cover,
      );
    }

    //------------------------------------------
    // NETWORK IMAGE
    //------------------------------------------

    if (controller.profile.profileImage.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: controller.profile.profileImage,
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (_, __, ___) => _defaultAvatar(),
      );
    }

    //------------------------------------------
    // DEFAULT
    //------------------------------------------

    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.person,
        size: 70,
        color: Colors.grey,
      ),
    );
  }
}