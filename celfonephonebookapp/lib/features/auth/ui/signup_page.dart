import 'dart:async';
import 'dart:math';

import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:celfonephonebookapp/features/auth/ui/login_page.dart';
import 'package:flutter/material.dart';
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
      });

      /// SUCCESS SMS API

      await http.post(
        Uri.parse(
          "http://bhashsms.com/api/sendmsg.php?user=Celfon_SMS&pass=123456&sender=CELFON&phone=$phone&text=Your Registration at CELFON BOOK is successful. Your Login Credentials are Username : $phone Password : $password Please login and edit your Business Profile (menu > my profile) to get more Trade Queries - CELFON&priority=ndnd&stype=normal",
        ),
      );

      showMsg("Registration Successful");

      if (!mounted) return;

      context.go('/home');
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
            : ElevatedButton(
                onPressed:
                    loading ||
                        checkingUser ||
                        userAlreadyExists ||
                        !validateMobile(phoneController.text)
                    ? null
                    : sendOtp,

                child: Text(otpSent ? "Resend" : "Send OTP"),
              ),
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

        Text(seconds == 0 ? "Resend Available" : "Resend OTP in $seconds sec"),
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

// import 'dart:io';
// import 'dart:math';

// import 'package:celfonephonebookapp/core/services/supabase_service.dart';
// import 'package:celfonephonebookapp/features/auth/ui/login_page.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:http/http.dart' as http;

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _promoController = TextEditingController();

//   bool _isMobileValid = false;

//   bool _loading = false;
//   bool _networkError = false;
//   String? _error;

//   bool _validateIndianMobile(String value) {
//     return RegExp(r'^[6-9]\d{9}$').hasMatch(value);
//   }

//   bool loading = false;

//   String generateOtp() {
//     final random = Random();
//     return (1000 + random.nextInt(9000)).toString();
//   }

//   Future<void> sendOtp(String phone) async {
//     if (phone.isEmpty) return;

//     final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
//     final otp = generateOtp();

//     setState(() => loading = true);

//     try {
//       // 🔥 CALL YOUR SMS API HERE
//       final response = await http.post(
//         Uri.parse(
//           "http://bhashsms.com/api/sendmsg.php?user=Celfon_SMS&pass=123456&sender=CELFON&phone=$cleanPhone&text=Your%20OTP%20for%20Signpost%20Celfon5G%20is:$otp.%20Use%20this%20OTP%20to%20verify%20your%20account.%20Do%20not%20share%20OTP%20with%20anyone.&priority=ndnd&stype=normal",
//         ),
//         body: {"phone": cleanPhone, "otp": otp},
//       );

//       if (response.statusCode == 200) {
//         // 🔥 Delete old OTPs (important)
//         await Supabase.instance.client
//             .from('otp_verifications')
//             .delete()
//             .eq('phone', cleanPhone);
//         // 🔥 Insert new OTP
//         await Supabase.instance.client.from('otp_verifications').insert({
//           'phone': cleanPhone,
//           'otp': otp,
//         });

//         if (!mounted) return;

//         // ✅ Navigate
//         context.go('/otp_verification', extra: cleanPhone);
//       } else {
//         throw Exception("Failed to send OTP");
//       }
//     } catch (e) {
//       debugPrint("Error: $e");

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Failed to send OTP")));
//     }

//     setState(() => loading = false);
//   }

//   Future<void> _signup() async {
//     if (_phoneController.text.trim().isEmpty) {
//       setState(() => _error = 'Phone number is required');
//       return;
//     }

//     if (!_validateIndianMobile(_phoneController.text.trim())) {
//       setState(() => _error = 'Enter valid mobile number');
//       return;
//     }

//     if (_nameController.text.trim().isEmpty) {
//       setState(() => _error = 'Full name is required');
//       return;
//     }

//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       String phone = _phoneController.text.trim();
//       String name = _nameController.text.trim();

//       /// 🔐 DEFAULT PASSWORD
//       const String defaultPassword = 'celfonbook';

//       final AuthResponse authRes = await SupabaseService.client.auth.signUp(
//         phone: phone,
//         password: defaultPassword,
//       );

//       final user = authRes.user;
//       if (user == null) {
//         throw Exception('User not created');
//       }

//       /// Save profile
//       await SupabaseService.client.from('s_profiles').insert({
//         'id': user.id,
//         'full_name': _nameController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'promo_code': _promoController.text.trim(),
//       });

//       if (!mounted) return;
//       await sendOtp(phone);
//       // _showSuccessPopup(phone, name);
//     } on AuthException catch (e) {
//       setState(() => _error = e.message);
//     } catch (e) {
//       setState(() => _error = 'Signup failed');
//     } finally {
//       setState(() => _loading = false);
//     }
//   }

//   void _showSuccessPopup(String phone, String name) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           child: Container(
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.black, width: 2),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// ✅ TITLE
//                 const Text(
//                   "Registration Successful",
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 const Text(
//                   "You Are Successfully Registered.",
//                   style: TextStyle(fontSize: 18),
//                 ),

//                 const SizedBox(height: 16),

//                 /// ✅ DETAILS
//                 const Text(
//                   "App : CELFON BOOK",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 10),

//                 Text(
//                   "Name : $name",
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 Text(
//                   "UN : $phone",
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),

//                 const SizedBox(height: 6),

//                 const Text(
//                   "PW: celfonbook",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),

//                 const SizedBox(height: 16),

//                 /// 📸 NOTE
//                 const Center(
//                   child: Text(
//                     "Please take a Screen Shot & save",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 /// ℹ️ INFO
//                 const Text(
//                   "If you are a Businessman, then fill your Business Details in the Menu > My Profile and get Trade Enquiries FREE",
//                   style: TextStyle(fontSize: 15),
//                 ),

//                 const SizedBox(height: 20),

//                 /// 🔘 ACTIONS
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     /// COPY BUTTON
//                     IconButton(
//                       icon: const Icon(Icons.copy),
//                       onPressed: () {
//                         Clipboard.setData(
//                           ClipboardData(
//                             text:
//                                 "App: CELFON BOOK\nName: $name\nUN: $phone\nPW: celfonbook",
//                           ),
//                         );

//                         ScaffoldMessenger.of(
//                           context,
//                         ).showSnackBar(const SnackBar(content: Text("Copied")));
//                       },
//                     ),

//                     /// OK BUTTON
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         context.go('/home');
//                       },
//                       child: const Text("OK"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_networkError) {
//       return Scaffold(body: _NetworkErrorView(onRetry: _signup));
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               /// 🔵 Header
//               Container(
//                 height: 260,
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Color.fromARGB(255, 23, 128, 198),
//                   borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(40),
//                     bottomRight: Radius.circular(40),
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     const Positioned(
//                       bottom: 32,
//                       left: 24,
//                       child: Text(
//                         'Create\nAccount',
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           height: 1.2,
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: Image.asset(
//                         'images/signup.png',
//                         height: 240,
//                         fit: BoxFit.contain,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 40),

//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     /// 📱 Mobile Number
//                     TextField(
//                       controller: _phoneController,
//                       keyboardType: TextInputType.phone,
//                       maxLength: 10,
//                       onChanged: (v) {
//                         setState(() {
//                           _isMobileValid = _validateIndianMobile(v);
//                         });
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'Mobile Number',
//                         counterText: '',
//                         prefixIcon: const Icon(Icons.phone_outlined),
//                         suffixIcon: _isMobileValid
//                             ? const Icon(
//                                 Icons.check_circle,
//                                 color: Colors.green,
//                               )
//                             : null,
//                         filled: true,
//                         fillColor: Colors.grey.shade100,
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 20,
//                           vertical: 18,
//                         ),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(14),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     /// 👤 Full Name
//                     _InputField(
//                       hint: 'Full Name',
//                       icon: Icons.person_outline,
//                       controller: _nameController,
//                     ),

//                     const SizedBox(height: 20),

//                     /// 🎁 Promo Code
//                     _InputField(
//                       hint: 'Promo Code (Optional)',
//                       icon: Icons.card_giftcard_outlined,
//                       controller: _promoController,
//                     ),

//                     if (_error != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 12),
//                         child: Text(
//                           _error!,
//                           style: const TextStyle(color: Colors.red),
//                         ),
//                       ),

//                     const SizedBox(height: 30),

//                     /// 🚀 SIGN UP BUTTON (Full Width Now)
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: GestureDetector(
//                         onTap: _loading ? null : _signup,
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 24),
//                           height: 56,
//                           decoration: BoxDecoration(
//                             color: Colors.black,
//                             borderRadius: BorderRadius.circular(28),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               const Text(
//                                 'Sign Up',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               _loading
//                                   ? const SizedBox(
//                                       height: 20,
//                                       width: 20,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         color: Colors.white,
//                                       ),
//                                     )
//                                   : const Icon(
//                                       Icons.arrow_forward,
//                                       color: Colors.white,
//                                     ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 40),

//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => const LoginPage()),
//                         );
//                       },
//                       child: const Text(
//                         'Already have an account? Login',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// 🔹 Reusable Input
// class _InputField extends StatelessWidget {
//   final String hint;
//   final IconData icon;
//   final TextEditingController controller;
//   final bool obscure;
//   final ValueChanged<String>? onChanged;

//   const _InputField({
//     required this.hint,
//     required this.icon,
//     required this.controller,
//     this.obscure = false,
//     this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         hintText: hint,
//         prefixIcon: Icon(icon, color: Colors.grey),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 20,
//           vertical: 18,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }

// class _NetworkErrorView extends StatelessWidget {
//   final VoidCallback onRetry;
//   const _NetworkErrorView({required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset('images/ic_launcher.png', width: 100),
//           const SizedBox(height: 20),
//           const Text(
//             'Check your network connection',
//             style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
//         ],
//       ),
//     );
//   }
// }
