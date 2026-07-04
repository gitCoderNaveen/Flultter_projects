import 'package:celfonephonebookapp/features/analytics/payments_page.dart';
import 'package:celfonephonebookapp/features/analytics/search_logs_page.dart';
import 'package:celfonephonebookapp/features/analytics/user_sessions_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      body: Stack(
        children: [
          ///=========================
          /// TOP GRADIENT
          ///=========================
          Container(
            height: 215,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff0569FF), Color(0xff19C8F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
          ),

          /// Decorative Circles
          Positioned(
            right: -35,
            top: 40,
            child: Container(
              height: 170,
              width: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.05),
              ),
            ),
          ),

          Positioned(
            right: 30,
            top: 60,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(.05),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 18),

                ///=========================
                /// LOGO
                ///=========================
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.08),
                              blurRadius: 15,
                            ),
                          ],
                        ),

                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: "Cel",
                                style: TextStyle(color: Colors.red),
                              ),

                              TextSpan(
                                text: "fon",
                                style: TextStyle(color: Colors.blue),
                              ),

                              TextSpan(
                                text: " Book",
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              indent: 40,
                              endIndent: 20,
                              color: Colors.white38,
                              thickness: 2,
                            ),
                          ),

                          const Text(
                            "Connects For Growth",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          Expanded(
                            child: Divider(
                              indent: 20,
                              endIndent: 40,
                              color: Colors.white38,
                              thickness: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                ///=========================
                /// WHITE BODY
                ///=========================
                Expanded(
                  child: Container(
                    width: double.infinity,

                    decoration: const BoxDecoration(
                      color: Color(0xffF8FAFD),

                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),

                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),

                      children: [
                        if (user != null)
                          buildMenuCard(
                            icon: Icons.person,
                            iconColor: Colors.blue,
                            title: "My Profile",
                            subtitle: "View and manage your profile",
                            onTap: () => context.push('/profile'),
                          ),

                        user == null
                            ? buildMenuCard(
                                icon: Icons.login,
                                iconColor: Colors.green,
                                title: "Login",
                                subtitle: "Sign in to your account",
                                onTap: () => context.push('/login'),
                              )
                            : buildMenuCard(
                                icon: Icons.logout,
                                iconColor: Colors.red,
                                title: "Logout",
                                subtitle: "Sign out from your account",
                                onTap: () async {
                                  await Supabase.instance.client.auth.signOut();

                                  if (!context.mounted) return;

                                  context.go('/home');
                                },
                              ),
                        buildMenuCard(
                          icon: Icons.people_alt_rounded,
                          iconColor: Colors.deepPurple,
                          title: "My Referral",
                          subtitle: "Invite friends and earn rewards",
                          onTap: () => context.push('/my_referral'),
                        ),

                        buildMenuCard(
                          icon: Icons.info,
                          iconColor: Colors.blue,
                          title: "About Us",
                          subtitle: "Know more about Celfon Book",
                          onTap: () => context.push('/about_us'),
                        ),

                        buildMenuCard(
                          icon: Icons.search,
                          iconColor: Colors.green,
                          title: "Reverse Number Finder",
                          subtitle: "Find details of any number",
                          onTap: () => context.push('/reverse_number_finder'),
                        ),

                        buildMenuCard(
                          icon: Icons.bar_chart,
                          iconColor: Colors.deepPurple,
                          title: "Branding Ads Tariffs",
                          subtitle: "View our advertising plans",
                          onTap: () => context.push('/subscription'),
                        ),

                        buildMenuCard(
                          icon: Icons.card_giftcard,
                          iconColor: Colors.orange,
                          title: "Combo Offers",
                          subtitle: "Check exciting combo offers",
                          onTap: () => context.push('/combo_offers'),
                        ),

                        buildMenuCard(
                          icon: Icons.logout,
                          iconColor: Colors.teal,
                          title: "Opt-Out",
                          subtitle: "Choose not to receive messages",
                          onTap: () => context.push('/opt_out'),
                        ),

                        buildMenuCard(
                          icon: Icons.verified_user,
                          iconColor: Colors.blue,
                          title: "OTP Verification",
                          subtitle: "Verify your mobile number",
                          onTap: () => context.push('/send_otp'),
                        ),

                        buildMenuCard(
                          icon: Icons.support_agent,
                          iconColor: Colors.pink,
                          title: "Contact Us",
                          subtitle: "Get in touch with our support",
                          onTap: () => context.push('/contact_us'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  } 
}

Widget buildMenuCard({
  required IconData icon,
  required Color iconColor,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                /// ICON
                Container(
                  height: 58,
                  width: 58,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: iconColor, size: 32),
                ),

                const SizedBox(width: 18),

                /// TITLE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  size: 34,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _HeaderRow extends StatelessWidget {
  final bool collapsed;
  const _HeaderRow({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final color = collapsed ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: "Cel",
                            style: TextStyle(color: Colors.red),
                          ),
                          TextSpan(
                            text: "fon",
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(
                            text: " Book",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    "Connects For Growth",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
