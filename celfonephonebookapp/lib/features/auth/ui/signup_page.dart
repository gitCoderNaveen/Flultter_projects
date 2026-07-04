import 'dart:async';
import 'dart:math';

import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:celfonephonebookapp/features/auth/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final nameController = TextEditingController();
  final promoController = TextEditingController();

  bool otpSent = false;
  bool otpVerified = false;

  bool loading = false;

  int seconds = 30;
  bool checkingUser = false;

  bool userAlreadyExists = false;

  String? mobileError;

  Timer? timer;

  String generatedOtp = "";
  @override
  void initState() {
    super.initState();

    phoneController.addListener(_refresh);

    nameController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  bool validateMobile(String value) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(value);
  }

  String createOtp() {
    return (1000 + Random().nextInt(9000)).toString();
  }

  void startTimer() {
    timer?.cancel();

    seconds = 30;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        setState(() {
          seconds--;
        });
      }
    });
  }

  Future<void> checkMobileExists(String mobile) async {
    if (mobile.length != 10) {
      setState(() {
        userAlreadyExists = false;

        mobileError = null;
      });

      return;
    }

    setState(() {
      checkingUser = true;
    });

    try {
      bool exists = false;

      /// CHECK PROFILE TABLE

      final profileResult = await SupabaseService.client
          .from('s_profiles')
          .select('phone')
          .eq('phone', mobile)
          .maybeSingle();

      if (profileResult != null) {
        exists = true;
      }

      /// CHECK AUTH USERS TABLE

      if (!exists) {
        final authResult = await SupabaseService.client.rpc(
          'check_phone_exists',
          params: {'p_phone': mobile},
        );

        exists = authResult == true;
      }

      setState(() {
        userAlreadyExists = exists;

        mobileError = exists ? "User already registered" : null;
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    setState(() {
      checkingUser = false;
    });
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) return;

    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    final otp = createOtp();

    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "http://bhashsms.com/api/sendmsg.php?user=Celfon_SMS&pass=123456&sender=CELFON&phone=$cleanPhone&text=Your OTP for Signpost Celfon5G is $otp. Use this OTP to verify your account. Do not share OTP with anyone.&priority=ndnd&stype=normal",
        ),
      );

      if (response.statusCode == 200) {
        generatedOtp = otp;

        await Supabase.instance.client
            .from('otp_verifications')
            .delete()
            .eq('phone', cleanPhone);

        await Supabase.instance.client.from('otp_verifications').insert({
          'phone': cleanPhone,

          'otp': otp,
        });

        setState(() {
          otpSent = true;
        });

        startTimer();

        showMsg("OTP Sent Successfully");
      } else {
        throw Exception();
      }
    } catch (e) {
      showMsg("Failed to Send OTP");
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> verifyOtp() async {
    try {
      final phone = phoneController.text.trim();

      final result = await Supabase.instance.client
          .from('otp_verifications')
          .select()
          .eq('phone', phone)
          .eq('otp', otpController.text.trim())
          .maybeSingle();

      if (result != null) {
        timer?.cancel();

        setState(() {
          otpVerified = true;
        });

        showMsg("Mobile Verified");
      } else {
        showMsg("Invalid OTP");
      }
    } catch (e) {
      showMsg("OTP Verification Failed");
    }
  }

  Future<void> signup() async {
    if (!otpVerified) {
      showMsg("Verify Mobile First");

      return;
    }

    if (nameController.text.trim().isEmpty) {
      showMsg("Enter Full Name");

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final phone = phoneController.text.trim();
      final userName = nameController.text.trim();

      const password = "celfonbook";

      final authRes = await SupabaseService.client.auth.signUp(
        phone: phone,

        password: password,
      );

      final user = authRes.user;

      if (user == null) {
        throw Exception();
      }

      await SupabaseService.client.from('s_profiles').insert({
        'id': user.id,

        'full_name': userName,

        'phone': phone,

        'promo_code': promoController.text.trim(),

        'verified':true,
      });

      /// SUCCESS SMS API

      await http.post(
        Uri.parse(
          "http://bhashsms.com/api/sendmsg.php?user=Celfon_SMS&pass=123456&sender=CELFON&phone=$phone&text=Your Registration at CELFON BOOK is successful. Your Login Credentials are Username : $phone Password : $password Please login and edit your Business Profile (menu > my profile) to get more Trade Queries - CELFON&priority=ndnd&stype=normal",
        ),
      );

      showMsg("Registration Successful");

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xffFFF3E0), Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.celebration, color: Colors.orange, size: 70),

                  const SizedBox(height: 10),

                  const Text(
                    "Registration Successful",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "You are successfully Registered",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "App : CELFON BOOK",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text("Name : $userName"),
                        Text("UN : $phone"),
                        const Text("PW : celfonbook"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Please Take a Screen Shot & Save",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "If you are a Businessman, then fill your Business Details in the Menu > My Profile and get Trade Enquiries FREE",
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text("Copy"),
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(
                                text:
                                    '''
                                      App: CELFON BOOK
                                      Name: $userName
                                      UN: $phone
                                      PW: celfonbook
                                    ''',
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Credentials copied"),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text("OK"),
                          onPressed: () {
                            Navigator.pop(context);
                            context.go('/home');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    } on AuthException catch (e) {
      showMsg(e.message);
    } catch (e) {
      showMsg("Signup Failed");
    }

    setState(() {
      loading = false;
    });
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    timer?.cancel();

    phoneController.removeListener(_refresh);

    nameController.removeListener(_refresh);

    phoneController.dispose();

    otpController.dispose();

    nameController.dispose();

    promoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              header(),

              Transform.translate(
                offset: const Offset(0, -40),

                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),

                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 20),
                    ],
                  ),

                  child: Column(
                    children: [
                      progress(),

                      const SizedBox(height: 30),

                      mobileSection(),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),

                        child: otpSent ? otpSection() : const SizedBox(),
                      ),

                      const SizedBox(height: 20),

                      formSection(),

                      const SizedBox(height: 30),

                      button(),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },

                        child: const Text("Already have account? Login"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Container(
      height: 220,

      width: double.infinity,

      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff1576FF), Color(0xff35A2FF)],
        ),

        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),

          bottomRight: Radius.circular(40),
        ),
      ),

      child: const Padding(
        padding: EdgeInsets.only(left: 24, top: 50),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Create\nAccount",

              style: TextStyle(
                fontSize: 34,

                fontWeight: FontWeight.bold,

                color: Colors.white,
              ),
            ),

            SizedBox(height: 10),

            // Text(
            //   "Join CelfonBook Today",

            //   style: TextStyle(color: Colors.white70, fontSize: 28, fontWeight: FontWeight(10)),
            // ),
          ],
        ),
      ),
    );
  }

  Widget progress() {
    return Row(
      children: [
        Icon(
          Icons.check_circle,

          color: otpVerified ? Colors.green : Colors.grey,
        ),

        const SizedBox(width: 8),

        const Text("Mobile Verification"),

        const Spacer(),

        Icon(Icons.person, color: otpVerified ? Colors.blue : Colors.grey),
      ],
    );
  }

  Widget mobileSection() {
    return TextField(
      enabled: !otpVerified,

      controller: phoneController,

      keyboardType: TextInputType.phone,

      maxLength: 10,

      onChanged: (value) {
        setState(() {
          otpSent = false;

          otpVerified = false;
        });

        if (value.length == 10) {
          checkMobileExists(value);
        } else {
          setState(() {
            mobileError = null;

            userAlreadyExists = false;
          });
        }
      },

      decoration: input(
        "Mobile Number",

        Icons.phone,

        suffix: checkingUser
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : otpVerified
            ? ElevatedButton(onPressed: null, child: const Text("Verified"))
            : !otpSent
            ? ElevatedButton(
                onPressed:
                    loading ||
                        checkingUser ||
                        userAlreadyExists ||
                        !validateMobile(phoneController.text)
                    ? null
                    : sendOtp,
                child: const Text("Send OTP"),
              )
            : seconds == 0
            ? ElevatedButton(onPressed: sendOtp, child: const Text("Resend"))
            : null,
      ).copyWith(counterText: "", errorText: mobileError),
    );
  }

  Widget otpSection() {
    return Column(
      children: [
        const SizedBox(height: 20),

        TextField(
          controller: otpController,

          keyboardType: TextInputType.number,

          decoration: input("Enter OTP", Icons.lock),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: otpVerified ? null : verifyOtp,

                child: Text(otpVerified ? "Verified ✓" : "Verify OTP"),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Text(
          otpVerified
              ? "Mobile Verified ✓"
              : seconds == 0
              ? "You can resend OTP now"
              : "Resend OTP in $seconds sec",
        ),
      ],
    );
  }

  Widget formSection() {
    return Column(
      children: [
        TextField(
          enabled: otpVerified,

          controller: nameController,

          decoration: input("Full Name", Icons.person),
        ),

        const SizedBox(height: 20),

        TextField(
          enabled: otpVerified,

          controller: promoController,

          decoration: input("Promo Code", Icons.card_giftcard),
        ),
      ],
    );
  }

  Widget button() {
    final bool disableButton =
        loading ||
        !otpVerified ||
        userAlreadyExists ||
        checkingUser ||
        phoneController.text.length != 10 ||
        nameController.text.trim().isEmpty;

    return SizedBox(
      width: double.infinity,

      height: 58,

      child: ElevatedButton(
        onPressed: disableButton ? null : signup,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,

          disabledBackgroundColor: Colors.grey.shade300,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        child: loading
            ? const SizedBox(
                width: 22,

                height: 22,

                child: CircularProgressIndicator(
                  strokeWidth: 2,

                  color: Colors.white,
                ),
              )
            : const Text(
                "Create Account",

                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFFFFF),
                ),
              ),
      ),
    );
  }

  InputDecoration input(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(icon),

      suffixIcon: suffix,

      filled: true,

      fillColor: Colors.grey.shade100,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),

        borderSide: BorderSide.none,
      ),
    );
  }
}
