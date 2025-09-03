// // import 'package:flutter/material.dart';
// //
// // class MediaPartnerSignupPage extends StatefulWidget {
// //   const MediaPartnerSignupPage({super.key});
// //
// //   @override
// //   State<MediaPartnerSignupPage> createState() => _MediaPartnerSignupPageState();
// // }
// //
// // class _MediaPartnerSignupPageState extends State<MediaPartnerSignupPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   bool isLoading = false;
// //
// //   // Controllers
// //   final orgNameController = TextEditingController();
// //   final contactPersonController = TextEditingController();
// //   final emailController = TextEditingController();
// //   final mobileController = TextEditingController();
// //   final websiteController = TextEditingController();
// //   final cityController = TextEditingController();
// //   final addressController = TextEditingController();
// //   final descriptionController = TextEditingController();
// //
// //   @override
// //   void dispose() {
// //     orgNameController.dispose();
// //     contactPersonController.dispose();
// //     emailController.dispose();
// //     mobileController.dispose();
// //     websiteController.dispose();
// //     cityController.dispose();
// //     addressController.dispose();
// //     descriptionController.dispose();
// //     super.dispose();
// //   }
// //
// //   // Validation
// //   String? validateMobile(String? value) {
// //     if (value == null || value.isEmpty) return "Enter mobile number";
// //     if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
// //       return "Enter valid Indian mobile number";
// //     }
// //     return null;
// //   }
// //
// //   String? validateEmail(String? value) {
// //     if (value == null || value.isEmpty) return "Enter email address";
// //     if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
// //       return "Enter valid email address";
// //     }
// //     return null;
// //   }
// //
// //   Future<void> _submitForm() async {
// //     if (!_formKey.currentState!.validate()) return;
// //
// //     setState(() => isLoading = true);
// //
// //     await Future.delayed(const Duration(seconds: 2)); // mock API call
// //
// //     if (!mounted) return;
// //     setState(() => isLoading = false);
// //
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text("Application submitted successfully!")),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Media Partner Application")),
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: SingleChildScrollView(
// //               padding: const EdgeInsets.all(16),
// //               child: Form(
// //                 key: _formKey,
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     const Text(
// //                       "Fill out the details below to apply as a Media Partner:",
// //                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
// //                     ),
// //                     const SizedBox(height: 20),
// //
// //                     // Org name
// //                     TextFormField(
// //                       controller: orgNameController,
// //                       decoration: const InputDecoration(
// //                         labelText: "Organization / Media Name",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                       validator: (val) =>
// //                       val == null || val.isEmpty ? "Enter organization name" : null,
// //                     ),
// //                     const SizedBox(height: 16),
// //
// //                     // Contact person
// //                     TextFormField(
// //                       controller: contactPersonController,
// //                       decoration: const InputDecoration(
// //                         labelText: "Contact Person",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                       validator: (val) =>
// //                       val == null || val.isEmpty ? "Enter contact person" : null,
// //                     ),
// //                     const SizedBox(height: 16),
// //
// //                     // Email
// //                     TextFormField(
// //                       controller: emailController,
// //                       decoration: const InputDecoration(
// //                         labelText: "Email",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                       validator: validateEmail,
// //                     ),
// //                     const SizedBox(height: 16),
// //
// //                     // Mobile
// //                     TextFormField(
// //                       controller: mobileController,
// //                       decoration: const InputDecoration(
// //                         labelText: "Mobile Number",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                       keyboardType: TextInputType.phone,
// //                       validator: validateMobile,
// //                     ),
// //                     const SizedBox(height: 16),
// //
// //                     // Website
// //                     TextFormField(
// //                       controller: websiteController,
// //                       decoration: const InputDecoration(
// //                         labelText: "Website (optional)",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 16),
// //
// //                     // City
// //                     TextFormField(
// //                       controller: cityController,
// //                       decoration: const InputDecoration(
// //                         labelText: "City",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 16),
// //
// //                     // Address
// //                     TextFormField(
// //                       controller: addressController,
// //                       decoration: const InputDecoration(
// //                         labelText: "Address",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                       maxLines: 2,
// //                     ),
// //                     const SizedBox(height: 16),
// //
// //                     // Description
// //                     TextFormField(
// //                       controller: descriptionController,
// //                       decoration: const InputDecoration(
// //                         labelText: "About Your Organization",
// //                         border: OutlineInputBorder(),
// //                       ),
// //                       maxLines: 4,
// //                     ),
// //                     const SizedBox(height: 100),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //           // Submit button
// //           Container(
// //             width: double.infinity,
// //             padding: const EdgeInsets.all(16),
// //             child: isLoading
// //                 ? const Center(child: CircularProgressIndicator())
// //                 : ElevatedButton.icon(
// //               onPressed: _submitForm,
// //               style: ElevatedButton.styleFrom(
// //                 minimumSize: const Size.fromHeight(50),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //               ),
// //               icon: const Icon(Icons.send),
// //               label: const Text("Submit Application"),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../supabase/supabase.dart';
// import './homepage_shell.dart';
//
// class MediaPartnerSignupPage extends StatefulWidget {
//   const MediaPartnerSignupPage({super.key});
//
//   @override
//   State<MediaPartnerSignupPage> createState() => _MediaPartnerSignupPageState();
// }
//
// class _MediaPartnerSignupPageState extends State<MediaPartnerSignupPage> {
//   final _formKey = GlobalKey<FormState>();
//   String signupType = "business"; // default = business
//   bool isLoading = false;
//
//   // Controllers
//   final mobileController = TextEditingController();
//   final emailController = TextEditingController();
//   final cityController = TextEditingController();
//   final pincodeController = TextEditingController();
//   final addressController = TextEditingController();
//
//   // Person
//   final personNameController = TextEditingController();
//   final personPrefixController = TextEditingController();
//   final professionController = TextEditingController();
//
//   // Business
//   final businessNameController = TextEditingController();
//   final businessPrefixController = TextEditingController();
//   final keywordsController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final landlineController = TextEditingController();
//   final landlineCodeController = TextEditingController();
//
//   // Live mobile check state
//   Timer? _debounce;
//   bool _isCheckingMobile = false;
//   bool _mobileExists = false;
//   String? _mobileMsg; // message shown under field
//   String _lastCheckToken = ""; // race-protection
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     mobileController.dispose();
//     emailController.dispose();
//     cityController.dispose();
//     pincodeController.dispose();
//     addressController.dispose();
//     personNameController.dispose();
//     personPrefixController.dispose();
//     professionController.dispose();
//     businessNameController.dispose();
//     businessPrefixController.dispose();
//     keywordsController.dispose();
//     descriptionController.dispose();
//     landlineController.dispose();
//     landlineCodeController.dispose();
//     super.dispose();
//   }
//
//   // ========== LIVE MOBILE CHECK ==========
//   void _onMobileChanged(String value) {
//     _debounce?.cancel();
//     setState(() {
//       _mobileMsg = null;
//       _mobileExists = false;
//     });
//
//     // Only check when looks like a valid Indian number
//     final trimmed = value.trim();
//     final isPatternOk = RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed);
//     if (!isPatternOk) return;
//
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       _checkMobileExists(trimmed);
//     });
//   }
//
//   Future<void> _checkMobileExists(String mobile) async {
//     final checkToken = mobile; // race-protection token
//     setState(() {
//       _isCheckingMobile = true;
//       _lastCheckToken = checkToken;
//     });
//
//     try {
//       final res = await SupabaseService.client
//           .from('profiles')
//           .select('business_name, person_name')
//           .eq('mobile_number', mobile)
//           .limit(1)
//           .maybeSingle();
//
//       // If user typed more after this request started, ignore result
//       if (!mounted || _lastCheckToken != checkToken) return;
//
//       if (res != null) {
//         final business = (res['business_name'] as String?)?.trim();
//         final person = (res['person_name'] as String?)?.trim();
//         setState(() {
//           _mobileExists = true;
//           _mobileMsg = business != null && business.isNotEmpty
//               ? "Mobile already registered with Business: $business"
//               : "Mobile already registered with Person: ${person ?? '-'}";
//         });
//       } else {
//         setState(() {
//           _mobileExists = false;
//           _mobileMsg = "Mobile available ✓";
//         });
//       }
//     } catch (e) {
//       // Likely RLS/permission or network error
//       setState(() {
//         _mobileExists = false;
//         _mobileMsg = "Couldn’t verify mobile (check RLS/connection)";
//       });
//     } finally {
//       if (mounted && _lastCheckToken == checkToken) {
//         setState(() => _isCheckingMobile = false);
//       }
//     }
//   }
//
//   // ========== SIGNUP ==========
//   // Future<void> _signup() async {
//   //   if (!_formKey.currentState!.validate()) return;
//   //
//   //   // One last quick check to prevent race condition signups
//   //   final mobile = mobileController.text.trim();
//   //   final isPatternOk = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);
//   //   if (!isPatternOk) {
//   //     ScaffoldMessenger.of(context)
//   //         .showSnackBar(const SnackBar(content: Text("Enter a valid Indian mobile number")));
//   //     return;
//   //   }
//   //
//   //   // If we already know it's taken, block
//   //   if (_mobileExists) {
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text(_mobileMsg ?? "Mobile already registered")),
//   //     );
//   //     return;
//   //   }
//   //
//   //   setState(() => isLoading = true);
//   //
//   //   const password = "signpost";
//   //   final emailAlias = "$mobile@celfon5g.com";
//   //
//   //   try {
//   //     // Auth signup
//   //     final authRes = await SupabaseService.client.auth.signUp(
//   //       email: emailAlias,
//   //       password: password,
//   //     );
//   //     final user = authRes.user;
//   //     if (user == null) throw Exception("User signup failed");
//   //
//   //     // Build profile payload
//   //     final Map<String, dynamic> profile = {
//   //       // ⚠️ If your schema has `user_id` NOT NULL, use "user_id": user.id
//   //       // and DO NOT set "id": user.id unless your PK equals auth uid.
//   //       // Update according to your actual table definition.
//   //       "user_type": signupType,
//   //       "mobile_number": mobile,
//   //       "email": emailController.text.trim(),
//   //       "city": cityController.text.trim(),
//   //       "pincode": pincodeController.text.trim(),
//   //       "address": addressController.text.trim(),
//   //       // if your table has user_id:
//   //       "id": user.id,
//   //     };
//   //
//   //     if (signupType == "person") {
//   //       profile.addAll({
//   //         "person_name": personNameController.text.trim(),
//   //         "person_prefix": personPrefixController.text.trim(),
//   //         "profession": professionController.text.trim(),
//   //       });
//   //     } else {
//   //       profile.addAll({
//   //         "business_name": businessNameController.text.trim(),
//   //         "business_prefix": businessPrefixController.text.trim(),
//   //         "keywords": keywordsController.text
//   //             .split(",")
//   //             .map((e) => e.trim())
//   //             .where((e) => e.isNotEmpty)
//   //             .toList(),
//   //         "description": descriptionController.text.trim(),
//   //         "landline": landlineController.text.trim(),
//   //         "landline_code": landlineCodeController.text.trim(),
//   //       });
//   //     }
//   //
//   //     await SupabaseService.client.from("profiles").insert(profile);
//   //
//   //     // Ensure session (auto-login) if signUp didn’t return session
//   //     if (authRes.session == null) {
//   //       final loginRes = await SupabaseService.client.auth.signInWithPassword(
//   //         email: emailAlias,
//   //         password: password,
//   //       );
//   //       if (loginRes.session == null) {
//   //         throw Exception("Auto-login failed");
//   //       }
//   //     }
//   //
//   //     if (!mounted) return;
//   //     Navigator.pushAndRemoveUntil(
//   //       context,
//   //       MaterialPageRoute(builder: (_) => const HomePageShell()),
//   //           (route) => false,
//   //     );
//   //   } catch (e) {
//   //     if (mounted) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text("Error: $e")),
//   //       );
//   //     }
//   //   } finally {
//   //     if (mounted) setState(() => isLoading = false);
//   //   }
//   // }
//
//   Future<void> addProfileRecord() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => isLoading = true);
//
//     try {
//       final user = SupabaseService.client.auth.currentUser;
//       if (user == null) throw Exception("User not logged in");
//       final currentUser = SupabaseService.client.auth.currentSession;
//       print("Current Session $currentUser");
//       // Build new record payload
//       final Map<String, dynamic> profile = {
//         "user_type": signupType,
//         "mobile_number": mobileController.text.trim(),
//         "email": emailController.text.trim(),
//         "city": cityController.text.trim(),
//         "pincode": pincodeController.text.trim(),
//         "address": addressController.text.trim(),
//       };
//
//       if (signupType == "person") {
//         profile.addAll({
//           "person_name": personNameController.text.trim(),
//           "person_prefix": personPrefixController.text.trim(),
//           "profession": professionController.text.trim(),
//         });
//       } else {
//         profile.addAll({
//           "business_name": businessNameController.text.trim(),
//           "business_prefix": businessPrefixController.text.trim(),
//           "keywords": keywordsController.text
//               .split(",")
//               .map((e) => e.trim())
//               .where((e) => e.isNotEmpty)
//               .toList(),
//           "description": descriptionController.text.trim(),
//           "landline": landlineController.text.trim(),
//           "landline_code": landlineCodeController.text.trim(),
//         });
//       }
//
//       // Insert new record
//       await SupabaseService.client.from("profiles").insert(profile);
//
//       // Show success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Record Added Successfully")),
//         );
//       }
//
//       print("user Id");
//       print(user.email);
//       print(user);
//       // Fetch current count of logged-in user
//       final userProfile = await SupabaseService.client
//           .from("profiles")
//           .select('count')
//           .eq('id', user.id)
//           .maybeSingle();
//
//       int currentCount = 0;
//       if (userProfile != null && userProfile['count'] != null) {
//         currentCount = int.tryParse(userProfile['count'] as String) ?? 0;
//       }
//
//       // Ensure first count starts at 1
//       final newCount = currentCount + 1;
//
//       // Update count column
//       await SupabaseService.client
//           .from("profiles")
//           .update({'count': newCount.toString()})
//           .eq('id', user.id);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e")),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }
//
//
//
//
//
//   // ========== Validators ==========
//   String? validateMobile(String? value) {
//     if (value == null || value.isEmpty) return "Enter mobile number";
//     if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
//       return "Enter valid Indian mobile number";
//     }
//     return null;
//   }
//
//   String? validatePincode(String? value) {
//     if (value == null || value.isEmpty) return "Enter pincode";
//     if (!RegExp(r'^\d{6}$').hasMatch(value)) return "Enter valid 6-digit pincode";
//     return null;
//   }
//
//   // ========== Forms ==========
//   Widget _buildPersonForm() => Column(
//     children: [
//       TextFormField(controller: personNameController, decoration: const InputDecoration(labelText: "Person Name")),
//       TextFormField(controller: personPrefixController, decoration: const InputDecoration(labelText: "Prefix (Mr/Ms/etc)")),
//       TextFormField(controller: professionController, decoration: const InputDecoration(labelText: "Profession")),
//     ],
//   );
//
//   Widget _buildBusinessForm() => Column(
//     children: [
//       TextFormField(controller: businessNameController, decoration: const InputDecoration(labelText: "Business Name")),
//       TextFormField(controller: businessPrefixController, decoration: const InputDecoration(labelText: "Prefix")),
//       TextFormField(controller: keywordsController, decoration: const InputDecoration(labelText: "Products (comma separated)")),
//       TextFormField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
//       TextFormField(controller: landlineController, decoration: const InputDecoration(labelText: "Landline")),
//       TextFormField(controller: landlineCodeController, decoration: const InputDecoration(labelText: "Landline Code")),
//     ],
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     final mobile = mobileController.text.trim();
//     final mobileLooksValid = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Media Partner")),
//       body: Column(
//         children: [
//           // Toggle buttons
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: ToggleButtons(
//               isSelected: [signupType == "person", signupType == "business"],
//               onPressed: (index) => setState(() => signupType = index == 0 ? "person" : "business"),
//               borderRadius: BorderRadius.circular(12),
//               selectedColor: Colors.white,
//               fillColor: Theme.of(context).primaryColor,
//               children: const [
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(children: [Icon(Icons.person), SizedBox(width: 8), Text("Person")]),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(children: [Icon(Icons.business), SizedBox(width: 8), Text("Business")]),
//                 ),
//               ],
//             ),
//           ),
//
//           // Scrollable form
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 400),
//                   transitionBuilder: (child, animation) => FadeTransition(
//                     opacity: animation,
//                     child: SlideTransition(
//                       position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero).animate(animation),
//                       child: child,
//                     ),
//                   ),
//                   child: Column(
//                     key: ValueKey(signupType),
//                     children: [
//                       TextFormField(
//                         controller: mobileController,
//                         decoration: InputDecoration(
//                           labelText: "Mobile Number",
//                           suffixIcon: _isCheckingMobile
//                               ? const Padding(
//                             padding: EdgeInsets.all(12),
//                             child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
//                           )
//                               : (mobileLooksValid && _mobileMsg != null)
//                               ? (_mobileExists
//                               ? const Icon(Icons.error, color: Colors.red)
//                               : const Icon(Icons.check_circle, color: Colors.green))
//                               : null,
//                         ),
//                         keyboardType: TextInputType.phone,
//                         validator: validateMobile,
//                         onChanged: _onMobileChanged,
//                       ),
//                       if (_mobileMsg != null)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 6),
//                           child: Align(
//                             alignment: Alignment.centerLeft,
//                             child: Text(
//                               _mobileMsg!,
//                               style: TextStyle(color: _mobileExists ? Colors.red : Colors.green, fontSize: 12),
//                             ),
//                           ),
//                         ),
//
//                       TextFormField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
//                       TextFormField(controller: cityController, decoration: const InputDecoration(labelText: "City")),
//                       TextFormField(
//                         controller: pincodeController,
//                         decoration: const InputDecoration(labelText: "Pincode"),
//                         validator: validatePincode,
//                       ),
//                       TextFormField(
//                         controller: addressController,
//                         decoration: const InputDecoration(labelText: "Address"),
//                         maxLines: 2,
//                       ),
//
//                       const SizedBox(height: 10),
//                       if (signupType == "person") _buildPersonForm(),
//                       if (signupType == "business") _buildBusinessForm(),
//                       const SizedBox(height: 80),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           // Fixed Sign Up button
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(16),
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : ElevatedButton.icon(
//               onPressed: addProfileRecord,
//               style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
//               icon: const Icon(Icons.check_circle),
//               label: Text("Save as ${signupType.capitalize()}"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// extension StringCasingExtension on String {
//   String capitalize() => isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabase/supabase.dart';
import './homepage_shell.dart';

class MediaPartnerSignupPage extends StatefulWidget {
  const MediaPartnerSignupPage({super.key});

  @override
  State<MediaPartnerSignupPage> createState() => _MediaPartnerSignupPageState();
}

class _MediaPartnerSignupPageState extends State<MediaPartnerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  String signupType = "business"; // default = business
  bool isLoading = false;

  // Controllers
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();

  // Door/street/area
  final doorNoController = TextEditingController();
  final streetController = TextEditingController();
  final areaController = TextEditingController();

  // Person
  final personNameController = TextEditingController();
  String? personPrefix = "Mr."; // dropdown default
  final professionController = TextEditingController();

  // Business
  final businessNameController = TextEditingController();
  String? businessPrefix = "M/s."; // dropdown default
  final keywordsController = TextEditingController();
  final descriptionController = TextEditingController();
  final landlineController = TextEditingController();
  final landlineCodeController = TextEditingController();

  Timer? _debounce;
  bool _isCheckingMobile = false;
  bool _mobileExists = false;
  String? _mobileMsg;
  String _lastCheckToken = "";

  @override
  void dispose() {
    _debounce?.cancel();
    mobileController.dispose();
    emailController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    doorNoController.dispose();
    streetController.dispose();
    areaController.dispose();
    personNameController.dispose();
    professionController.dispose();
    businessNameController.dispose();
    keywordsController.dispose();
    descriptionController.dispose();
    landlineController.dispose();
    landlineCodeController.dispose();
    super.dispose();
  }

  // ========== LIVE MOBILE CHECK ==========
  void _onMobileChanged(String value) {
    _debounce?.cancel();
    setState(() {
      _mobileMsg = null;
      _mobileExists = false;
    });

    final trimmed = value.trim();
    final isPatternOk = RegExp(r'^[6-9]\d{9}$').hasMatch(trimmed);
    if (!isPatternOk) return;

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _checkMobileExists(trimmed);
    });
  }

  Future<void> _checkMobileExists(String mobile) async {
    final checkToken = mobile;
    setState(() {
      _isCheckingMobile = true;
      _lastCheckToken = checkToken;
    });

    try {
      final res = await SupabaseService.client
          .from('profiles')
          .select('business_name, person_name')
          .eq('mobile_number', mobile)
          .maybeSingle();

      if (!mounted || _lastCheckToken != checkToken) return;

      if (res != null) {
        final business = (res['business_name'] as String?)?.trim();
        final person = (res['person_name'] as String?)?.trim();
        setState(() {
          _mobileExists = true;
          _mobileMsg = business != null && business.isNotEmpty
              ? "Mobile already registered with Business: $business"
              : "Mobile already registered with Person: ${person ?? '-'}";
        });
      } else {
        setState(() {
          _mobileExists = false;
          _mobileMsg = "Mobile available ✓";
        });
      }
    } catch (e) {
      setState(() {
        _mobileExists = false;
        _mobileMsg = "Couldn’t verify mobile (check RLS/connection)";
      });
    } finally {
      if (mounted && _lastCheckToken == checkToken) {
        setState(() => _isCheckingMobile = false);
      }
    }
  }

  Future<void> addProfileRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final fetchUser = await SharedPreferences.getInstance();
      final user = fetchUser.getString("userName");
      if (user == null) throw Exception("User not logged in");

      // Build new record payload
      final Map<String, dynamic> profile = {
        "user_type": signupType,
        "mobile_number": mobileController.text.trim(),
        "email": emailController.text.trim(),
        "city": cityController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "door_no": doorNoController.text.trim(),
        "street": streetController.text.trim(),
        "area": areaController.text.trim(),
      };

      if (signupType == "person") {
        profile.addAll({
          "person_name": personNameController.text.trim(),
          "person_prefix": personPrefix,
          "profession": professionController.text.trim(),
        });
      } else {
        profile.addAll({
          "business_name": businessNameController.text.trim(),
          "business_prefix": businessPrefix,
          "keywords": keywordsController.text
              .split(",")
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          "description": descriptionController.text.trim(),
          "landline": landlineController.text.trim(),
          "landline_code": landlineCodeController.text.trim(),
        });
      }

      // Insert new record
      await SupabaseService.client.from("profiles").insert(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Record Added Successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ========== Validators ==========
  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter mobile number";
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return "Enter valid Indian mobile number";
    }
    return null;
  }

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) return "Enter pincode";
    if (!RegExp(r'^\d{6}$').hasMatch(value)) return "Enter valid 6-digit pincode";
    return null;
  }

  // ========== Forms ==========
  Widget _buildPersonForm() => Column(
    children: [
      TextFormField(
          controller: personNameController,
          decoration: const InputDecoration(labelText: "Person Name")),
      DropdownButtonFormField<String>(
        value: personPrefix,
        items: const [
          DropdownMenuItem(value: "Mr.", child: Text("Mr.")),
          DropdownMenuItem(value: "Ms.", child: Text("Ms.")),
          DropdownMenuItem(value: "Lions", child: Text("Lions")),
          DropdownMenuItem(value: "Others", child: Text("Others")),
        ],
        onChanged: (val) => setState(() => personPrefix = val),
        decoration: const InputDecoration(labelText: "Prefix"),
      ),
      TextFormField(
          controller: professionController,
          decoration: const InputDecoration(labelText: "Profession")),
    ],
  );

  Widget _buildBusinessForm() => Column(
    children: [
      TextFormField(
          controller: businessNameController,
          decoration: const InputDecoration(labelText: "Business Name")),
      DropdownButtonFormField<String>(
        value: businessPrefix,
        items: const [
          DropdownMenuItem(value: "M/s.", child: Text("M/s.")),
        ],
        onChanged: (val) => setState(() => businessPrefix = val),
        decoration: const InputDecoration(labelText: "Prefix"),
      ),
      TextFormField(
          controller: keywordsController,
          decoration:
          const InputDecoration(labelText: "Products (comma separated)")),
      TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(labelText: "Description")),
      TextFormField(
          controller: landlineController,
          decoration: const InputDecoration(labelText: "Landline")),
      TextFormField(
          controller: landlineCodeController,
          decoration: const InputDecoration(labelText: "Landline Code")),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final mobile = mobileController.text.trim();
    final mobileLooksValid = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);

    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: Column(
        children: [
          // Toggle buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: ToggleButtons(
              isSelected: [signupType == "person", signupType == "business"],
              onPressed: (index) =>
                  setState(() => signupType = index == 0 ? "person" : "business"),
              borderRadius: BorderRadius.circular(12),
              selectedColor: Colors.white,
              fillColor: Theme.of(context).primaryColor,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                      children: [Icon(Icons.person), SizedBox(width: 8), Text("Person")]),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(children: [
                    Icon(Icons.business),
                    SizedBox(width: 8),
                    Text("Business")
                  ]),
                ),
              ],
            ),
          ),

          // Scrollable form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                          begin: const Offset(0.2, 0), end: Offset.zero)
                          .animate(animation),
                      child: child,
                    ),
                  ),
                  child: Column(
                    key: ValueKey(signupType),
                    children: [
                      TextFormField(
                        controller: mobileController,
                        decoration: InputDecoration(
                          labelText: "Mobile Number",
                          suffixIcon: _isCheckingMobile
                              ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)),
                          )
                              : (mobileLooksValid && _mobileMsg != null)
                              ? (_mobileExists
                              ? const Icon(Icons.error, color: Colors.red)
                              : const Icon(Icons.check_circle,
                              color: Colors.green))
                              : null,
                        ),
                        keyboardType: TextInputType.phone,
                        validator: validateMobile,
                        onChanged: _onMobileChanged,
                      ),
                      if (_mobileMsg != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _mobileMsg!,
                              style: TextStyle(
                                  color:
                                  _mobileExists ? Colors.red : Colors.green,
                                  fontSize: 12),
                            ),
                          ),
                        ),
                      TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: "Email")),
                      TextFormField(
                          controller: cityController,
                          decoration: const InputDecoration(labelText: "City")),
                      TextFormField(
                        controller: pincodeController,
                        decoration:
                        const InputDecoration(labelText: "Pincode"),
                        validator: validatePincode,
                      ),
                      const SizedBox(height: 10),

                      // Door/Street/Area
                      TextFormField(
                        controller: doorNoController,
                        decoration: const InputDecoration(labelText: "Door No"),
                      ),
                      TextFormField(
                        controller: streetController,
                        decoration: const InputDecoration(labelText: "Street"),
                      ),
                      TextFormField(
                        controller: areaController,
                        decoration: const InputDecoration(labelText: "Area"),
                      ),
                      const SizedBox(height: 10),

                      if (signupType == "person") _buildPersonForm(),
                      if (signupType == "business") _buildBusinessForm(),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Fixed Sign Up button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              onPressed: addProfileRecord,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50)),
              icon: const Icon(Icons.check_circle),
              label: Text("Save as ${signupType.capitalize()}"),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() =>
      isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
}
