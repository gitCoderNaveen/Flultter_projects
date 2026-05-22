import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyOtpPage extends StatefulWidget {
  final String phone;
  const VerifyOtpPage({super.key, required this.phone});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final List<TextEditingController> controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  bool loading = false;

  String getOtp() {
    return controllers.map((e) => e.text).join();
  }

  Future<bool> verifyOtp(String phone, String enteredOtp) async {
    try {
      final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

      /// ✅ CHECK OTP
      final result = await Supabase.instance.client
          .from('otp_verifications')
          .select()
          .eq('phone', cleanPhone)
          .eq('otp', enteredOtp)
          .maybeSingle();

      if (result == null) {
        return false;
      }

      /// ✅ UPDATE VERIFIED COLUMN
      await Supabase.instance.client
          .from('s_profiles')
          .update({'verified': true})
          .eq('phone', cleanPhone);

      /// ✅ DELETE OTP AFTER SUCCESS
      await Supabase.instance.client
          .from('otp_verifications')
          .delete()
          .eq('phone', cleanPhone);

      return true;
    } catch (e) {
      debugPrint("Verify OTP Error: $e");
      return false;
    }
  }

  Future<void> handleVerify() async {
    final otp = getOtp();

    if (otp.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter complete OTP")));
      return;
    }

    setState(() => loading = true);

    try {
      final success = await verifyOtp(widget.phone, otp);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("OTP Verified 🎉"),
            backgroundColor: Colors.green,
          ),
        );

        /// ✅ SEND PHONE NUMBER
        context.go('/verify_success', extra: widget.phone);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Invalid OTP ❌")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error verifying OTP")));
    }

    setState(() => loading = false);
  }

  Widget otpBox(int index) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: controllers[index],
        maxLength: 1,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          counterText: "",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              /// 🔥 Title
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: "Cel",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    TextSpan(
                      text: "fon",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    TextSpan(
                      text: " Book",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Subtitle
              const Text(
                "OTP Verification...",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 40),

              /// Enter OTP Text
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter OTP",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              /// OTP Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, otpBox),
              ),

              const SizedBox(height: 50),

              /// Button
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
                  onPressed: loading ? null : handleVerify,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Verify OTP",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
