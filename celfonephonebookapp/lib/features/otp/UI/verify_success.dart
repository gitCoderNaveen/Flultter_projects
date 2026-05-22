import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifySuccessPage extends StatefulWidget {
  final String phone;

  const VerifySuccessPage({super.key, required this.phone});

  @override
  State<VerifySuccessPage> createState() => _VerifySuccessPageState();
}

class _VerifySuccessPageState extends State<VerifySuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> scaleAnim;
  late Animation<double> opacityAnim;

  @override
  void initState() {
    super.initState();
    updateVerifiedStatus();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    scaleAnim = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    opacityAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  Future<void> updateVerifiedStatus() async {
    try {
      final cleanPhone = widget.phone.replaceAll(RegExp(r'\D'), '');

      /// ✅ UPDATE VERIFIED TRUE
      await Supabase.instance.client
          .from('profiles')
          .update({'verified': true})
          .eq('mobile_number', cleanPhone);

      debugPrint("Verified updated successfully");
    } catch (e) {
      debugPrint("Update verified error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildCheckIcon() {
    return Container(
      width: 160,
      height: 160,
      decoration: const BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 80),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.phone,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),

            /// Animation area
            FadeTransition(
              opacity: opacityAnim,
              child: ScaleTransition(
                scale: scaleAnim,
                child: Column(
                  children: [
                    buildCheckIcon(),
                    const SizedBox(height: 30),
                    const Text(
                      "Verified Successfully...",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),

            /// ✅ Done Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => context.go('/home'),
                child: const Text("Done", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
