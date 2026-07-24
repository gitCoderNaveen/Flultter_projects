import 'package:cached_network_image/cached_network_image.dart';
import 'package:celfonephonebookapp/features/home/model/directory_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CityDirectoryCard extends StatelessWidget {
  final DirectoryModel city;

  const CityDirectoryCard({super.key, required this.city});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),

      onTap: () {
        final c = Uri.encodeComponent(city.city);

        context.push("/search?city=$c");
      },

      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),

        child: Stack(
          fit: StackFit.expand,

          children: [
            CachedNetworkImage(imageUrl: city.imageUrl, fit: BoxFit.cover),

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,

                  end: Alignment.center,

                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
            ),

            Positioned(
              left: 18,

              bottom: 18,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    city.city,

                    style: const TextStyle(
                      color: Colors.white,

                      fontWeight: FontWeight.bold,

                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    "Explore Businesses",

                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
