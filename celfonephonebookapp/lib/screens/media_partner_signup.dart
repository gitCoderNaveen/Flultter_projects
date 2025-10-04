// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import '../supabase/supabase.dart';
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
//   bool isLoading = false;
//
//   // Controllers
//   final mobileController = TextEditingController();
//   final emailController = TextEditingController();
//   final cityController = TextEditingController();
//   final pincodeController = TextEditingController();
//   final doorNoController = TextEditingController();
//   final streetController = TextEditingController();
//   final areaController = TextEditingController();
//
//   final personNameController = TextEditingController();
//   String? personPrefix = "Mr.";
//   final professionController = TextEditingController();
//
//   final businessNameController = TextEditingController();
//   String? businessPrefix = "M/s.";
//   final keywordsController = TextEditingController();
//   final descriptionController = TextEditingController();
//   final landlineController = TextEditingController();
//   final landlineCodeController = TextEditingController();
//
//   // Image picker
//   final ImagePicker _picker = ImagePicker();
//   List<File> _selectedImages = [];
//
//   // Mobile validation
//   Timer? _debounce;
//   bool _isPersonSelected = true;
//   bool _isCheckingMobile = false;
//   bool _mobileExists = false;
//   String? _mobileMsg;
//   String _lastCheckToken = "";
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     mobileController.dispose();
//     emailController.dispose();
//     cityController.dispose();
//     pincodeController.dispose();
//     doorNoController.dispose();
//     streetController.dispose();
//     areaController.dispose();
//     personNameController.dispose();
//     professionController.dispose();
//     businessNameController.dispose();
//     keywordsController.dispose();
//     descriptionController.dispose();
//     landlineController.dispose();
//     landlineCodeController.dispose();
//     super.dispose();
//   }
//
//   // ===== Mobile Live Check =====
//   void _onMobileChanged(String value) {
//     _debounce?.cancel();
//     setState(() {
//       _mobileMsg = null;
//       _mobileExists = false;
//     });
//
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
//     final checkToken = mobile;
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
//           .maybeSingle();
//
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
//   // ===== Image Picker =====
//   Future<void> _pickImages() async {
//     final picked = await _picker.pickMultiImage(imageQuality: 80);
//     if (picked.isNotEmpty) {
//       setState(() {
//         _selectedImages.addAll(picked.map((x) => File(x.path)));
//       });
//     }
//   }
//
//   Future<void> addProfileRecord() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     if (_mobileExists) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("This mobile number is already registered")),
//       );
//       return;
//     }
//
//     setState(() => isLoading = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString("userId");
//       final userName = prefs.getString("username"); // saved at login/signup
//       if (userId == null || userName == null) {
//         throw Exception("User not logged in");
//       }
//
//       // ---------------------------
//       // 1. Insert Profile Record
//       // ---------------------------
//       final profile = {
//         "mobile_number": mobileController.text.trim(),
//         "email": emailController.text.trim(),
//         "city": cityController.text.trim(),
//         "pincode": pincodeController.text.trim(),
//         "address": addressController.text.trim(),
//         "person_name": personNameController.text.trim(),
//         "person_prefix": personPrefix,
//         "business_name": businessNameController.text.trim(),
//         "business_prefix": businessPrefix,
//         "user_type": _isPersonSelected ? "person" : "business",
//         "keywords": keywordsController.text.trim(),
//         "landline": landlineController.text.trim(),
//         "landline_code": landlineCodeController.text.trim(),
//       };
//
//       await SupabaseService.client.from("profiles").insert(profile);
//
//       // ---------------------------
//       // 2. Update data_entry_table
//       // ---------------------------
//       final now = DateTime.now().toUtc();
//       final todayStart = DateTime.utc(now.year, now.month, now.day, 0, 0, 0);
//       final todayEnd = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);
//
//       final existing = await SupabaseService.client
//           .from("data_entry_table")
//           .select()
//           .eq("user_id", userId)
//           .gte("created_at", todayStart.toIso8601String())
//           .lte("created_at", todayEnd.toIso8601String())
//           .maybeSingle();
//
//       // ---------------------------
//       // Earnings Calculation Rules
//       // ---------------------------
//       int earningsToAdd = 0;
//
//       final allFilled = profile.values.every((v) {
//         if (v is String) return v.trim().isNotEmpty;
//         if (v is List) return v.isNotEmpty;
//         return false;
//       });
//
//       if (allFilled) {
//         earningsToAdd = 10;
//       } else if (
//       profile["mobile_number"].toString().isNotEmpty &&
//           profile["email"].toString().isNotEmpty &&
//           profile["city"].toString().isNotEmpty &&
//           profile["person_name"].toString().isNotEmpty &&
//           profile["person_prefix"].toString().isNotEmpty) {
//         earningsToAdd = 2;
//       } else if (
//       profile["mobile_number"].toString().isNotEmpty &&
//           profile["email"].toString().isNotEmpty &&
//           profile["city"].toString().isNotEmpty &&
//           profile["business_name"].toString().isNotEmpty &&
//           profile["pincode"].toString().isNotEmpty &&
//           profile["business_prefix"].toString().isNotEmpty &&
//           (profile["keywords"] as List).isNotEmpty &&
//           profile["description"].toString().isNotEmpty) {
//         earningsToAdd = 3;
//       }
//
//       if (existing != null) {
//         final prevCount = existing["count"] as int? ?? 0;
//         final prevEarnings = existing["earnings"] as int? ?? 0;
//
//         await SupabaseService.client
//             .from("data_entry_table")
//             .update({
//           "count": prevCount + 1,
//           "earnings": prevEarnings + earningsToAdd,
//           "updated_at": now.toIso8601String(),
//         })
//             .eq("id", existing["id"]);
//       } else {
//         await SupabaseService.client.from("data_entry_table").insert({
//           "user_id": userId,
//           "user_name": userName,
//           "count": 1,
//           "earnings": earningsToAdd,
//           "created_at": now.toIso8601String(),
//           "updated_at": now.toIso8601String(),
//         });
//       }
//
//       // ---------------------------
//       // 3. Insert into data_entry_name
//       // ---------------------------
//       final entryName = businessNameController.text.trim().isNotEmpty
//           ? businessNameController.text.trim()
//           : personNameController.text.trim();
//
//       final inserted = await SupabaseService.client
//           .from("data_entry_name")
//           .insert({
//         "user_id": userId,
//         "username": userName,
//         "entry_name": entryName,
//         "created_at": now.toIso8601String(),
//         "updated_at": now.toIso8601String(),
//       })
//           .select()
//           .maybeSingle();
//
//       // ---------------------------
//       // 4. Update scheme column based on earnings
//       // ---------------------------
//       if (earningsToAdd > 0 && inserted != null) {
//         String schemeMessage = "";
//         if (earningsToAdd == 10) {
//           schemeMessage = "You've Earn ₹10.";
//         } else if (earningsToAdd == 2) {
//           schemeMessage = "You've Earn ₹2.";
//         } else if (earningsToAdd == 3) {
//           schemeMessage = "You've Earn ₹3.";
//         }
//
//         if (schemeMessage.isNotEmpty) {
//           await SupabaseService.client
//               .from("data_entry_name")
//               .update({"scheme": schemeMessage})
//               .eq("id", inserted["id"]);
//         }
//       }
//
//       // ---------------------------
//       // 5. Reset Form
//       // ---------------------------
//       mobileController.clear();
//       emailController.clear();
//       cityController.clear();
//       pincodeController.clear();
//       doorNoController.clear();
//       streetController.clear();
//       areaController.clear();
//       personNameController.clear();
//       professionController.clear();
//       businessNameController.clear();
//       keywordsController.clear();
//       descriptionController.clear();
//       landlineController.clear();
//       landlineCodeController.clear();
//
//       setState(() {
//         personPrefix = "Mr.";
//         businessPrefix = "M/s.";
//       });
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Record Added Successfully")),
//         );
//       }
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
//
//
//   // ===== Validators =====
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
//     if (!RegExp(r'^\d{6}$').hasMatch(value)) {
//       return "Enter valid 6-digit pincode";
//     }
//     return null;
//   }
//
//   // ===== UI =====
//   @override
//   @override
//   Widget build(BuildContext context) {
//     final mobile = mobileController.text.trim();
//     final mobileLooksValid = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Data Entry")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               // Toggle: Person or Business
//               ToggleButtons(
//                 isSelected: [_isPersonSelected, !_isPersonSelected],
//                 onPressed: (index) {
//                   setState(() {
//                     _isPersonSelected = index == 0;
//                   });
//                 },
//                 borderRadius: BorderRadius.circular(12),
//                 selectedColor: Colors.white,
//                 fillColor: Theme.of(context).primaryColor,
//                 children: const [
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: Text("Person"),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 20),
//                     child: Text("Business"),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//
//               TextFormField(
//                 controller: mobileController,
//                 decoration: InputDecoration(
//                   labelText: "Mobile Number",
//                   suffixIcon: _isCheckingMobile
//                       ? const Padding(
//                     padding: EdgeInsets.all(12),
//                     child: SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(strokeWidth: 2)),
//                   )
//                       : (mobileLooksValid && _mobileMsg != null)
//                       ? (_mobileExists
//                       ? const Icon(Icons.error, color: Colors.red)
//                       : const Icon(Icons.check_circle, color: Colors.green))
//                       : null,
//                 ),
//                 keyboardType: TextInputType.phone,
//                 validator: validateMobile,
//                 onChanged: _onMobileChanged,
//               ),
//               if (_mobileMsg != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 6),
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       _mobileMsg!,
//                       style: TextStyle(
//                         color: _mobileExists ? Colors.red : Colors.green,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),
//                 ),
//
//               TextFormField(
//                   controller: emailController,
//                   decoration: const InputDecoration(labelText: "Email")),
//               TextFormField(
//                   controller: cityController,
//                   decoration: const InputDecoration(labelText: "City")),
//               TextFormField(
//                 controller: pincodeController,
//                 decoration: const InputDecoration(labelText: "Pincode"),
//                 validator: validatePincode,
//               ),
//               TextFormField(
//                   controller: doorNoController,
//                   decoration: const InputDecoration(labelText: "Door No")),
//               TextFormField(
//                   controller: streetController,
//                   decoration: const InputDecoration(labelText: "Street")),
//               TextFormField(
//                   controller: areaController,
//                   decoration: const InputDecoration(labelText: "Area")),
//
//               const SizedBox(height: 20),
//
//               // Person Fields
//               if (_isPersonSelected) ...[
//                 TextFormField(
//                     controller: personNameController,
//                     decoration: const InputDecoration(labelText: "Person Name")),
//                 DropdownButtonFormField<String>(
//                   value: personPrefix,
//                   items: const [
//                     DropdownMenuItem(value: "Mr.", child: Text("Mr.")),
//                     DropdownMenuItem(value: "Ms.", child: Text("Ms.")),
//                     DropdownMenuItem(value: "Lions", child: Text("Lions")),
//                     DropdownMenuItem(value: "Others", child: Text("Others")),
//                   ],
//                   onChanged: (val) => setState(() => personPrefix = val),
//                   decoration: const InputDecoration(labelText: "Person Prefix"),
//                 ),
//                 TextFormField(
//                     controller: professionController,
//                     decoration: const InputDecoration(labelText: "Profession")),
//               ],
//
//               // Business Fields
//               if (!_isPersonSelected) ...[
//                 TextFormField(
//                     controller: businessNameController,
//                     decoration: const InputDecoration(labelText: "Business Name")),
//                 DropdownButtonFormField<String>(
//                   value: businessPrefix,
//                   items: const [
//                     DropdownMenuItem(value: "M/s.", child: Text("M/s.")),
//                   ],
//                   onChanged: (val) => setState(() => businessPrefix = val),
//                   decoration: const InputDecoration(labelText: "Business Prefix"),
//                 ),
//                 TextFormField(
//                     controller: keywordsController,
//                     decoration: const InputDecoration(labelText: "Products (comma separated)")),
//                 TextFormField(
//                     controller: descriptionController,
//                     decoration: const InputDecoration(labelText: "Description")),
//                 TextFormField(
//                     controller: landlineController,
//                     decoration: const InputDecoration(labelText: "Landline")),
//                 TextFormField(
//                     controller: landlineCodeController,
//                     decoration: const InputDecoration(labelText: "Landline Code")),
//               ],
//
//               const SizedBox(height: 20),
//
//               Row(
//                 children: [
//                   ElevatedButton.icon(
//                     onPressed: _pickImages,
//                     icon: const Icon(Icons.add_a_photo),
//                     label: const Text("Upload Images"),
//                   ),
//                   const SizedBox(width: 10),
//                   Text("Selected: ${_selectedImages.length}"),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               if (_selectedImages.isNotEmpty)
//                 SizedBox(
//                   height: 90,
//                   child: ListView(
//                     scrollDirection: Axis.horizontal,
//                     children: _selectedImages
//                         .map((f) => Padding(
//                       padding: const EdgeInsets.all(4),
//                       child: Image.file(f, width: 80, height: 80, fit: BoxFit.cover),
//                     ))
//                         .toList(),
//                   ),
//                 ),
//
//               const SizedBox(height: 30),
//               isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : ElevatedButton.icon(
//                 onPressed: addProfileRecord,
//                 icon: const Icon(Icons.check_circle),
//                 label: Text(_isPersonSelected ? "Save Person Profile" : "Save Business Profile"),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
// }
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../supabase/supabase.dart';

class MediaPartnerSignupPage extends StatefulWidget {
  const MediaPartnerSignupPage({super.key});

  @override
  State<MediaPartnerSignupPage> createState() => _MediaPartnerSignupPageState();
}

class _MediaPartnerSignupPageState extends State<MediaPartnerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  // Controllers
  final mobileController = TextEditingController();
  final emailController = TextEditingController();
  final cityController = TextEditingController();
  final pincodeController = TextEditingController();
  final addressController = TextEditingController();

  final personNameController = TextEditingController();
  String? personPrefix = "";
  final professionController = TextEditingController();

  final businessNameController = TextEditingController();
  String? businessPrefix = "M/s.";
  final keywordsController = TextEditingController();

  final landlineController = TextEditingController();
  final landlineCodeController = TextEditingController();

  // Image picker
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];

  // Mobile validation
  Timer? _debounce;
  bool _isPersonSelected = true;
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
    addressController.dispose();
    personNameController.dispose();
    professionController.dispose();
    businessNameController.dispose();
    keywordsController.dispose();
    landlineController.dispose();
    landlineCodeController.dispose();
    super.dispose();
  }

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

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  Future<void> addProfileRecord() async {
    if (!_formKey.currentState!.validate()) return;

    if (_mobileExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("This mobile number is already registered")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("userId");
      final userName = prefs.getString("username");
      if (userId == null || userName == null) {
        throw Exception("User not logged in");
      }

      final profile = {
        "mobile_number": mobileController.text.trim(),
        "email": emailController.text.trim(),
        "city": cityController.text.trim(),
        "pincode": pincodeController.text.trim(),
        "address": addressController.text.trim(),
        "person_name": personNameController.text.trim(),
        "person_prefix": personPrefix,
        "business_name": businessNameController.text.trim(),
        "business_prefix": businessPrefix,
        "user_type": _isPersonSelected ? "person" : "business",
        "keywords": keywordsController.text.trim(),
        "landline": landlineController.text.trim(),
        "landline_code": landlineCodeController.text.trim(),
      };

      await SupabaseService.client.from("profiles").insert(profile);

      // Earnings Calculation Logic
      int earningsToAdd = 0;

      bool hasBasicInfo = profile["mobile_number"].toString().isNotEmpty &&
          profile["city"].toString().isNotEmpty &&
          profile["pincode"].toString().isNotEmpty &&
          profile["address"].toString().isNotEmpty &&
          ((_isPersonSelected && profile["person_name"].toString().isNotEmpty) ||
              (!_isPersonSelected && profile["business_name"].toString().isNotEmpty));

      if (hasBasicInfo) {
        earningsToAdd += 1;
      }

      if (profile["keywords"].toString().isNotEmpty) {
        earningsToAdd += 1;
      }

      if (profile["email"].toString().isNotEmpty) {
        earningsToAdd += 0.5.toInt();  // Converting to integer, earnings should likely be stored as int
      }

      final now = DateTime.now().toUtc();
      final todayStart = DateTime.utc(now.year, now.month, now.day, 0, 0, 0);
      final todayEnd = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);

      final existing = await SupabaseService.client
          .from("data_entry_table")
          .select()
          .eq("user_id", userId)
          .gte("created_at", todayStart.toIso8601String())
          .lte("created_at", todayEnd.toIso8601String())
          .maybeSingle();

      if (existing != null) {
        final prevCount = existing["count"] as int? ?? 0;
        final prevEarnings = existing["earnings"] as int? ?? 0;

        await SupabaseService.client
            .from("data_entry_table")
            .update({
          "count": prevCount + 1,
          "earnings": prevEarnings + earningsToAdd,
          "updated_at": now.toIso8601String(),
        })
            .eq("id", existing["id"]);
      } else {
        await SupabaseService.client.from("data_entry_table").insert({
          "user_id": userId,
          "user_name": userName,
          "count": 1,
          "earnings": earningsToAdd,
          "created_at": now.toIso8601String(),
          "updated_at": now.toIso8601String(),
        });
      }

      final entryName = businessNameController.text.trim().isNotEmpty
          ? businessNameController.text.trim()
          : personNameController.text.trim();

      final inserted = await SupabaseService.client
          .from("data_entry_name")
          .insert({
        "user_id": userId,
        "username": userName,
        "entry_name": entryName,
        "created_at": now.toIso8601String(),
        "updated_at": now.toIso8601String(),
      })
          .select()
          .maybeSingle();

      if (earningsToAdd > 0 && inserted != null) {
        String schemeMessage = "You've Earn ₹$earningsToAdd.";
        await SupabaseService.client
            .from("data_entry_name")
            .update({"scheme": schemeMessage})
            .eq("id", inserted["id"]);
      }

      mobileController.clear();
      emailController.clear();
      cityController.clear();
      pincodeController.clear();
      addressController.clear();
      personNameController.clear();
      professionController.clear();
      businessNameController.clear();
      keywordsController.clear();
      landlineController.clear();
      landlineCodeController.clear();

      setState(() {
        personPrefix = "Mr.";
        businessPrefix = "M/s.";
      });

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


  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) return "Enter mobile number";
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
      return "Enter valid Indian mobile number";
    }
    return null;
  }

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) return "Enter pincode";
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return "Enter valid 6-digit pincode";
    }
    return null;
  }

  String? mandatoryFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) return "This field is required";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final mobile = mobileController.text.trim();
    final mobileLooksValid = RegExp(r'^[6-9]\d{9}$').hasMatch(mobile);

    return Scaffold(
      appBar: AppBar(title: const Text("Data Entry")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Toggle for Person / Business
              ToggleButtons(
                isSelected: [_isPersonSelected, !_isPersonSelected],
                onPressed: (index) {
                  setState(() {
                    _isPersonSelected = index == 0;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                selectedColor: Colors.white,
                fillColor: Theme.of(context).primaryColor,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Person"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Firms"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              /// Common: Mobile Number
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
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
                        color: _mobileExists ? Colors.red : Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              /// ================== PERSON MODE ==================
              if (_isPersonSelected) ...[
                TextFormField(
                  controller: personNameController,
                  decoration: const InputDecoration(labelText: "Person Name"),
                  validator: mandatoryFieldValidator,
                ),
                const SizedBox(height: 12),

                /// Prefix (Radio Buttons)
                Row(
                  children: [
                    const Text("Prefix:"),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<String>(
                            value: "Mr.",
                            groupValue: personPrefix,
                            onChanged: (val) =>
                                setState(() => personPrefix = val),
                          ),
                          const Text("Mr."),
                          Radio<String>(
                            value: "Ms.",
                            groupValue: personPrefix,
                            onChanged: (val) =>
                                setState(() => personPrefix = val),
                          ),
                          const Text("Ms."),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: businessNameController,
                  decoration:
                  const InputDecoration(labelText: "Firm Name"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: "City"),
                  validator: mandatoryFieldValidator,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: pincodeController,
                  decoration: const InputDecoration(labelText: "Pincode"),
                  validator: validatePincode,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                  validator: mandatoryFieldValidator,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: professionController,
                  decoration:
                  const InputDecoration(labelText: "Profession"),
                  // validator: mandatoryFieldValidator,
                  onChanged: (val) =>
                  keywordsController.text = val.trim(), // sync keywords
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: landlineController,
                  decoration: const InputDecoration(labelText: "Land Line"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: landlineCodeController,
                  decoration: const InputDecoration(labelText: "STD Code"),
                ),
              ],

              /// ================== BUSINESS MODE ==================
              if (!_isPersonSelected) ...[
                TextFormField(
                  controller: businessNameController,
                  decoration:
                  const InputDecoration(labelText: "Firm Name"),
                  validator: mandatoryFieldValidator,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: personNameController,
                  decoration: const InputDecoration(labelText: "Person Name"),
                  onChanged: (val) =>
                  personNameController.text = val.trim(),
                ),
                const SizedBox(height: 12),

                /// Prefix (Radio Buttons)
                Row(
                  children: [
                    const Text("Prefix:"),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Radio<String>(
                            value: "Mr.",
                            groupValue: personPrefix,
                            onChanged: (val) =>
                                setState(() => personPrefix = val),
                          ),
                          const Text("Mr."),
                          Radio<String>(
                            value: "Ms.",
                            groupValue: personPrefix,
                            onChanged: (val) =>
                                setState(() => personPrefix = val),
                          ),
                          const Text("Ms."),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: "City"),
                  validator: mandatoryFieldValidator,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: pincodeController,
                  decoration: const InputDecoration(labelText: "Pincode"),
                  validator: validatePincode,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                  validator: mandatoryFieldValidator,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: professionController,
                  decoration:
                  InputDecoration(labelText: _isPersonSelected ? "Profession":"Products"),
                  onChanged: (val) =>
                  keywordsController.text = val.trim(),
                  // validator: mandatoryFieldValidator,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: landlineController,
                  decoration: const InputDecoration(labelText: "Land Line"),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: landlineCodeController,
                  decoration: const InputDecoration(labelText: "STD Code"),
                ),
              ],

              const SizedBox(height: 30),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                          onPressed: () {
                          final form = _formKey.currentState!;
                          if (!form.validate()) {
                          // Show alert if validation fails
                          showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                          title: const Text("Missing Fields"),
                          content: const Text("Please fill the mandatory fields."),
                          actions: [
                          TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text("OK"),
                          ),
                          ],
                          ),
                          );

        // Find and focus the first invalid field
        Future.delayed(Duration(milliseconds: 300), () {
        final firstInvalid = _formKey.currentContext!
            .findRenderObject();
        if (firstInvalid != null) {
        FocusScope.of(context).unfocus(); // close keyboard
        FocusScope.of(context).requestFocus(FocusNode()); // reset focus
        }
        });

        return;
        }

        // If validation passes → save record
        addProfileRecord();
        },
        icon: const Icon(Icons.check_circle),
        label: Text(
        _isPersonSelected ? "Save Person Profile" : "Save Firm Profile",
        ),
        ),
            ],
          ),
        ),
      ),
    );
  }

}
