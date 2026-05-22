import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SendOtpPage extends StatefulWidget {
  const SendOtpPage({super.key});

  @override
  State<SendOtpPage> createState() => _SendOtpPageState();
}

class _SendOtpPageState extends State<SendOtpPage> {
  final TextEditingController phoneController = TextEditingController();
  bool loading = false;

  String generateOtp() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString();
  }

  Future<void> sendOtp(String phone) async {
    if (phone.isEmpty) return;

    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    final otp = generateOtp();

    setState(() => loading = true);

    try {
      // 🔥 CALL YOUR SMS API HERE
      final response = await http.post(
        Uri.parse("http://bhashsms.com/api/sendmsg.php?user=Celfon_SMS&pass=123456&sender=CELFON&phone=$cleanPhone&text=Your%20OTP%20for%20Signpost%20Celfon5G%20is:$otp.%20Use%20this%20OTP%20to%20verify%20your%20account.%20Do%20not%20share%20OTP%20with%20anyone.&priority=ndnd&stype=normal"),
        body: {"phone": cleanPhone, "otp": otp},
      ); 

      if (response.statusCode == 200) {
        // 🔥 Delete old OTPs (important)
        await Supabase.instance.client
            .from('otp_verifications')
            .delete()
            .eq('phone', cleanPhone);
        // 🔥 Insert new OTP
        await Supabase.instance.client.from('otp_verifications').insert({
          'phone': cleanPhone,
          'otp': otp,
        });

        // ✅ Navigate
        context.go('/otp_verification', extra: cleanPhone);
      } else {
        throw Exception("Failed to send OTP");
      }
    } catch (e) {
      debugPrint("Error: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to send OTP")));
    }

    setState(() => loading = false);
  }

  @override
  void dispose() {
    phoneController.dispose();
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

              const SizedBox(height: 60),

              /// Label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter Your Number",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              /// Input Field
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 40),

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
                  onPressed: loading
                      ? null
                      : () => sendOtp(phoneController.text),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Send OTP", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
