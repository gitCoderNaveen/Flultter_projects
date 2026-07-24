import 'package:celfonephonebookapp/theme/app_colors.dart';
import 'package:celfonephonebookapp/theme/app_radius.dart';
import 'package:celfonephonebookapp/theme/app_shadows.dart';
import 'package:celfonephonebookapp/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumHomeHeader extends StatelessWidget {
  const PremiumHomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: 220,
      collapsedHeight: 90,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: _HeaderContent(),
    );
  }
}

class _HeaderContent extends StatelessWidget {
  const _HeaderContent();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final collapsed = constraints.maxHeight < 120;

        return AnimatedContainer(
          duration: 300.ms,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.headerGradient1, AppColors.headerGradient2],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AnimatedOpacity(
                          opacity: collapsed ? .0 : 1,
                          duration: 250.ms,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "👋 Good Morning",
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Welcome Back",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                "Connects For Growth",
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.white24,
                        child: IconButton(
                          icon: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),

                      const SizedBox(width: 10),

                      const CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage("images/ic_launcher.png"),
                      ),
                    ],
                  ),

                  const Spacer(),

                  _SearchCard(),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "search",

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xxl),

          onTap: () {
            context.push("/search");
          },

          child: Container(
            height: 58,

            padding: const EdgeInsets.symmetric(horizontal: 18),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(AppRadius.xxl),

              boxShadow: AppShadows.medium,
            ),

            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.primary),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "Search Business, Person...",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(8),

                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.08),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.tune,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fade(duration: 600.ms).slideY(begin: .4);
  }
}
