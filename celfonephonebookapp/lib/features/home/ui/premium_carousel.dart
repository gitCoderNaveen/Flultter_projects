import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:celfonephonebookapp/features/home/controller/home_controller.dart';
import 'package:celfonephonebookapp/features/home/ui/home_page.dart';
import 'package:celfonephonebookapp/theme/app_radius.dart';
import 'package:celfonephonebookapp/theme/app_shadows.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:skeletonizer/skeletonizer.dart';


class PremiumCarousel extends StatefulWidget {
  final HomeController controller;

  const PremiumCarousel({
    super.key,
    required this.controller,
  });

  @override
  State<PremiumCarousel> createState() => _PremiumCarouselState();
}

class _PremiumCarouselState extends State<PremiumCarousel> {
  late final PageController pageController;

  Timer? timer;

  int current = 0;

  @override
  void initState() {
    super.initState();

    pageController = PageController(viewportFraction: .93);

    timer = Timer.periodic(
      const Duration(seconds: 4),
      (_) {
        if (!mounted) return;

        if (widget.controller.carouselImages.isEmpty) return;

        current++;

        if (current >= widget.controller.carouselImages.length) {
          current = 0;
        }

        pageController.animateToPage(
          current,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [

          SizedBox(
            height: 185,

            child: Skeletonizer(
              enabled: controller.loading,

              child: PageView.builder(
                controller: pageController,

                itemCount: controller.carouselImages.length,

                onPageChanged: (index) {
                  setState(() {
                    current = index;
                  });
                },

                itemBuilder: (_, index) {

                  final banner = controller.carouselImages[index];

                  return GestureDetector(
                    onTap: () {

                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => FullScreenImage(
                            imageUrl: banner.redirectUrl,
                            heroTag: "banner$index",
                          ),
                        ),
                      );
                    },

                    child: Hero(
                      tag: "banner$index",

                      child: Container(
                        margin: const EdgeInsets.only(right: 10),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppRadius.lg,
                          ),

                          boxShadow: AppShadows.medium,
                        ),

                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.lg),

                          child: Stack(
                            fit: StackFit.expand,

                            children: [

                              CachedNetworkImage(
                                imageUrl: banner.imageUrl,

                                fit: BoxFit.cover,

                                placeholder: (_, __) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                  );
                                },

                                errorWidget: (_, __, ___) {
                                  return const Icon(Icons.broken_image);
                                },
                              ),

                              Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.center,

                                    colors: [
                                      Colors.black54,
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fade()
                      .scale(
                        begin: const Offset(.95, .95),
                      );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: List.generate(
              controller.carouselImages.length,

              (index) {

                final active = current == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),

                  margin: const EdgeInsets.symmetric(horizontal: 4),

                  width: active ? 22 : 8,

                  height: 8,

                  decoration: BoxDecoration(
                    color: active
                        ? Colors.blue
                        : Colors.grey.shade300,

                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}