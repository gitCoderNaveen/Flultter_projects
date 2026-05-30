import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for Recent Leads
    final List<Map<String, String>> recentLeads = [
      {'name': 'Arun Kumar', 'phone': '+91 98765 43210'},
      {'name': 'Rajesh Sharma', 'phone': '+91 87654 32109'},
      {'name': 'Suresh Benjamin', 'phone': '+91 76543 21098'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE6F4FE), // Smooth base background
      body: Stack(
        children: [
          // --- MODERN ABSTRACT BACKGROUND SHAPES ---
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3AB1FF).withOpacity(0.4),
                    blurRadius: 90,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8CE3FF).withOpacity(0.35),
                    blurRadius: 100,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),

          // --- MAIN UI LAYOUT ---
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // --- TOP HEADER WITH BACK BUTTON ---
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          child: IconButton(
                            onPressed: () {
                              context.pop(); // Back navigation
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF1E293B),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B), // Dark Navy Slate
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 28,
                    ), // Spacing between Header and Profile
                    // --- MODERN PROFILE SECTION ---
                    Row(
                      children: [
                        // Avatar Container with Premium Ring
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.8),
                                Colors.white.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.white24,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Profile Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'John Michael',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'johnmichael@email.com',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(
                                    0xFF1E293B,
                                  ).withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                '+1 (555) 123-4567',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(
                                    0xFF1E293B,
                                  ).withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // --- EDIT PROFILE ACTION BUTTON ---
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            context.push('/profile');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.edit_rounded,
                                  color: Color(0xFF1E293B),
                                  size: 14,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(
                                      0xFF1E293B,
                                    ).withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // --- TWO STATIC STAT CARDS ROW (VIEWS & LEADS) ---
                    Row(
                      children: const [
                        Expanded(
                          child: StatCard(value: '1.2k', title: 'Views'),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: StatCard(value: '84', title: 'Leads'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // --- RECENT LEADS SECTION TITLE ---
                    const Text(
                      'Recent Leads',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // --- RECENT LEADS LIST VIEW ---
                    ListView.separated(
                      shrinkWrap: true,
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentLeads.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final lead = recentLeads[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.45),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.6),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Lead Initials Circle Avatar
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(
                                      0xFF3AB1FF,
                                    ).withOpacity(0.2),
                                    child: Text(
                                      lead['name']![0], // First letter of name
                                      style: const TextStyle(
                                        color: Color(0xFF1E293B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Lead Details (Name & Mobile)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          lead['name']!,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          lead['phone']!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(
                                              0xFF1E293B,
                                            ).withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Frosted Modern Call Action Button
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        // Ungaloda dynamic calling function trigger pannikonga bro
                                      },
                                      icon: const Icon(
                                        Icons.phone_forwarded_rounded,
                                        color: Color(0xFF3AB1FF),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20), // Bottom safe margin
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PREMIUM REUSABLE STAT CARD ---
class StatCard extends StatelessWidget {
  final String value;
  final String title;

  const StatCard({super.key, required this.value, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B).withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
