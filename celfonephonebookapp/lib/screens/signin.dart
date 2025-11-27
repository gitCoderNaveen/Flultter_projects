// import 'package:flutter/material.dart';
// import '../supabase/supabase.dart';
// import 'homepage_shell.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import './signup.dart';
//
// class SigninPage extends StatefulWidget {
//   const SigninPage({super.key});
//
//   @override
//   State<SigninPage> createState() => _SigninPageState();
// }
//
// class _SigninPageState extends State<SigninPage> {
//   final _formKey = GlobalKey<FormState>();
//   final mobileController = TextEditingController();
//   bool _isLoading = false;
//
//   Future<void> _signIn() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _isLoading = true);
//
//     final mobile = mobileController.text.trim();
//
//     try {
//       // 🔎 Check profiles table
//       final profile = await SupabaseService.client
//           .from("profiles")
//           .select("id, business_name, person_name")
//           .eq("mobile_number", mobile)
//           .maybeSingle();
//
//       if (profile == null) {
//         // ❌ Not found → show alert with Signup option
//         if (mounted) {
//           await showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text("Invalid Mobile Number"),
//               content: const Text(
//                   "This mobile number is not registered. Please sign up first."),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const SignupPage()),
//                     );
//                   },
//                   child: const Text("Sign Up"),
//                 ),
//               ],
//             ),
//           );
//         }
//       } else {
//         // ✅ Found → resolve name preference
//         final business = (profile["business_name"] as String?)?.trim();
//         final person = (profile["person_name"] as String?)?.trim();
//
//         final username = (business != null && business.isNotEmpty)
//             ? business
//             : (person ?? "");
//
//         final userId = profile["id"].toString();
//
//         // Save to local storage
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString("username", username);
//         await prefs.setString("userId", userId);
//
//         debugPrint("✅ Logged in as $username ($userId)");
//
//         if (mounted) {
//           Navigator.pushAndRemoveUntil(
//             context,
//             MaterialPageRoute(builder: (_) => const HomePageShell()),
//                 (route) => false,
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e")),
//         );
//       }
//     }
//
//     if (mounted) setState(() => _isLoading = false);
//   }
//
//   String? validateMobile(String? value) {
//     if (value == null || value.isEmpty) return "Enter mobile number";
//     if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
//       return "Enter valid Indian mobile number";
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[200],
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Card(
//             elevation: 6,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       "Sign In",
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//
//                     // Mobile Input
//                     TextFormField(
//                       controller: mobileController,
//                       decoration: const InputDecoration(
//                         labelText: "Mobile Number",
//                         border: OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.phone),
//                       ),
//                       keyboardType: TextInputType.phone,
//                       validator: validateMobile,
//                     ),
//                     const SizedBox(height: 20),
//
//                     // Sign In Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _signIn,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? const CircularProgressIndicator(
//                           color: Colors.white,
//                         )
//                             : const Text(
//                           "Sign In",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 12),
//
//                     // Signup link
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (_) => const SignupPage()),
//                         );
//                       },
//                       child: const Text("Create an Account? Sign Up"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../supabase/supabase.dart';
import 'homepage_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './signup.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final _formKey = GlobalKey<FormState>();
  final mobileController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final mobile = mobileController.text.trim();

    try {
      // 🔎 Check profiles table
      final profile = await SupabaseService.client
          .from("profiles")
          .select("id, business_name, person_name")
          .eq("mobile_number", mobile)
          .maybeSingle();

      if (profile == null) {
        // ❌ Not found → show alert with Signup option
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Invalid Mobile Number"),
              content: const Text(
                  "This mobile number is not registered. Please sign up first."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupPage()),
                    );
                  },
                  child: const Text("Sign Up"),
                ),
              ],
            ),
          );
        }
      } else {
        // ✅ Found → resolve name preference
        final business = (profile["business_name"] as String?)?.trim();
        final person = (profile["person_name"] as String?)?.trim();

        final username = (business != null && business.isNotEmpty)
            ? business
            : (person ?? "");

        final userId = profile["id"].toString();

        // 💾 Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("username", username);
        await prefs.setString("userId", userId);

        // 🆕 Ensure users_table row exists (insert only if not exists)
        try {
          // 1️⃣ Check if record already exists
          final existing = await SupabaseService.client
              .from('users_table')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();

          if (existing == null) {
            // 2️⃣ Not exists → insert new row
            await SupabaseService.client.from('users_table').insert({
              'user_id': userId,
              'user_name': username,
              // 'cover_photo': null, // set later from profile/edit screen if needed
            });
          }
        } catch (e) {
          // Don’t block login if this fails; just log it.
          debugPrint('Error ensuring users_table row: $e');
        }

        debugPrint("✅ Logged in as $username ($userId)");

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePageShell()),
                (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter mobile number";
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return "Enter valid Indian mobile number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Mobile Input
                    TextFormField(
                      controller: mobileController,
                      decoration: const InputDecoration(
                        labelText: "Mobile Number",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: validateMobile,
                    ),
                    const SizedBox(height: 20),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text(
                          "Sign In",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Signup link
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const SignupPage()),
                        );
                      },
                      child: const Text("Create an Account? Sign Up"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
