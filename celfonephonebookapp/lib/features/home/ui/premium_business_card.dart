import 'package:cached_network_image/cached_network_image.dart';
import 'package:celfonephonebookapp/theme/app_radius.dart';
import 'package:celfonephonebookapp/theme/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


class PremiumBusinessCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const PremiumBusinessCard({
    super.key,
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(

      borderRadius:
          BorderRadius.circular(AppRadius.lg),

      onTap: onTap,

      child: Container(

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(AppRadius.lg),

          boxShadow: AppShadows.soft,
        ),

        child: Padding(

          padding: const EdgeInsets.all(16),

          child: Column(

            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [

              Hero(

                tag: title,

                child: CircleAvatar(

                  radius: 34,

                  backgroundColor:
                      Colors.grey.shade100,

                  child: CachedNetworkImage(
                    imageUrl: image,
                    width: 46,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(

                title,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                textAlign: TextAlign.center,

                style: const TextStyle(

                  fontWeight: FontWeight.bold,

                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              Container(

                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),

                decoration: BoxDecoration(

                  color: Colors.green.shade50,

                  borderRadius:
                      BorderRadius.circular(30),
                ),

                child: const Text(

                  "Verified",

                  style: TextStyle(

                    color: Colors.green,

                    fontWeight: FontWeight.w600,

                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fade()
        .scale();
  }
}