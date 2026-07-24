import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../controller/referral_controller.dart';

class ReferPage extends StatelessWidget {
  const ReferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReferralController(),
      child: const _ReferView(),
    );
  }
}

class _ReferView extends StatelessWidget {
  const _ReferView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReferralController>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FB),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        title: const Text(
          "Refer & Earn",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const _HeroSection(),

            const SizedBox(height: 25),

            const _CampaignCard(),

            const SizedBox(height: 25),

            const _CouponDashboard(),

            const SizedBox(height: 20),

            const _ProgressCard(),

            const SizedBox(height: 25),

            const _ReferralForm(),

            const SizedBox(height: 30),

            const _ReferralHistory(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _CouponDashboard extends StatelessWidget {
  const _CouponDashboard();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ReferralController>();

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.card_giftcard,

            color: Colors.orange,

            title: "Coupons",

            value: "${c.coupons}",
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: _StatCard(
            icon: Icons.people,

            color: Colors.green,

            title: "Successful",

            value: "${c.successfulReferrals}",
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;

  final Color color;

  final String title;

  final String value;

  const _StatCard({
    required this.icon,

    required this.color,

    required this.title,

    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 12)],
      ),

      child: Column(
        children: [
          CircleAvatar(
            radius: 26,

            backgroundColor: color.withOpacity(.15),

            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(height: 14),

          Text(
            value,

            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
          ),

          const SizedBox(height: 5),

          Text(title),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Lottie.asset("images/gift.json", height: 180, repeat: true),

        const SizedBox(height: 12),

        const Text(
          "Refer To Win",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          "Invite your friends and win exciting rewards.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),

        gradient: const LinearGradient(
          colors: [Color(0xffFF7043), Color(0xffE53935)],

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(.25),

            blurRadius: 20,

            offset: const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        children: [
          const Icon(Icons.electric_scooter, color: Colors.white, size: 65),

          const SizedBox(height: 18),

          const Text(
            "🎉 Win a Brand New EV Scooter",

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 22,

              fontWeight: FontWeight.bold,

              color: Colors.white,
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            "Invite your friends to use CELFON BOOK.",

            textAlign: TextAlign.center,

            style: TextStyle(color: Colors.white, fontSize: 16),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),

              borderRadius: BorderRadius.circular(16),
            ),

            child: const Text(
              "Every 3 successful referrals earns you 1 Coupon.\n\nMore coupons = More chances to win!",

              textAlign: TextAlign.center,

              style: TextStyle(
                color: Colors.white,

                fontSize: 16,

                height: 1.5,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferralForm extends StatelessWidget {
  const _ReferralForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReferralController>();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 15,
            color: Color(0x11000000),
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Refer Your Friend",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            "Enter your friend's details below.",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 25),

          _NameField(controller),

          const SizedBox(height: 20),

          _PhoneField(controller),

          const SizedBox(height: 18),

          // _PickContactButton(controller),

          const SizedBox(height: 30),

          _ReferButton(controller),
        ],
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final ReferralController controller;

  const _NameField(this.controller);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.nameController,

      textCapitalization: TextCapitalization.words,

      decoration: InputDecoration(
        labelText: "Friend Name",

        hintText: "Enter full name",

        prefixIcon: const Icon(Icons.person),

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final ReferralController controller;

  const _PhoneField(this.controller);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.phoneController,

      keyboardType: TextInputType.phone,

      maxLength: 10,

      decoration: InputDecoration(
        counterText: "",

        labelText: "Mobile Number",

        hintText: "9876543210",

        prefixIcon: const Icon(Icons.phone),

        prefixText: "+91 ",

        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _PickContactButton extends StatelessWidget {
  final ReferralController controller;

  const _PickContactButton(this.controller);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      height: 55,

      child: OutlinedButton.icon(
        icon: const Icon(Icons.contacts),

        label: const Text(
          "Choose From Contacts",

          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),

        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        onPressed: controller.pickContact,
      ),
    );
  }
}

class _ReferButton extends StatelessWidget {
  final ReferralController controller;

  const _ReferButton(this.controller);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      height: 58,

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,

          foregroundColor: Colors.white,

          elevation: 3,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),

        onPressed: controller.loading
            ? null
            : () async {
                final result = await controller.submit();

                if (!context.mounted) return;

                if (result == null) {
                  showDialog(
                    context: context,

                    builder: (_) => const _SuccessDialog(),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result)));
                }
              },

        child: controller.loading
            ? const SizedBox(
                width: 25,

                height: 25,

                child: CircularProgressIndicator(
                  strokeWidth: 3,

                  color: Colors.white,
                ),
              )
            : const Text(
                "Refer Now",

                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),

      content: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),

          const SizedBox(height: 20),

          const Text(
            "Referral Sent!",

            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),

          const SizedBox(height: 15),

          const Text(
            "Your invitation has been prepared.\n\nThe SMS app will open for you to send it.",

            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text("OK"),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ReferralController>();

    final progress = (c.successfulReferrals % 3) / 3;

    final remaining = 3 - (c.successfulReferrals % 3);

    return Container(
      padding: const EdgeInsets.all(22),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            "Next Coupon Progress",

            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          LinearProgressIndicator(
            value: progress,

            minHeight: 10,

            borderRadius: BorderRadius.circular(10),
          ),

          const SizedBox(height: 14),

          Text(
            "$remaining more successful referrals to earn your next coupon.",
          ),
        ],
      ),
    );
  }
}

class _ReferralHistory extends StatelessWidget {
  const _ReferralHistory();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<ReferralController>();

    if (c.referrals.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text(
          "Referral History",

          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),

        const SizedBox(height: 18),

        ...c.referrals.map(
          (e) => Card(
            margin: const EdgeInsets.only(bottom: 12),

            child: ListTile(
              leading: CircleAvatar(
                child: Text(e.referredName.substring(0, 1)),
              ),

              title: Text(e.referredName),

              subtitle: Text(e.referredPhone),

              trailing: e.joined
                  ? const Chip(label: Text("Joined"))
                  : const Chip(label: Text("Pending")),
            ),
          ),
        ),
      ],
    );
  }
}
