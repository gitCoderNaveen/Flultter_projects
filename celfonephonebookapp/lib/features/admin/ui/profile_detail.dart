// import 'dart:io';

// import 'package:celfonephonebookapp/features/admin/model/profile_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ProfileDetailScreen extends StatefulWidget {
//   final Map<dynamic, dynamic> profile;
//   const ProfileDetailScreen({super.key, required this.profile});

//   @override
//   State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
// }

// class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
//   late Map<String, dynamic> profile;
//   final SupabaseClient supabase = Supabase.instance.client;
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     profile = Map<String, dynamic>.from(widget.profile);
//   }

//   bool _isForbiddenField(String key) {
//     const forbidden = [
//       'id',
//       'created_at',
//       'user_type',
//       'profile_image',
//       'updated_at',
//       'auth_id',
//       'role',
//       'views',
//       'business_address',
//     ];
//     return forbidden.contains(key.toLowerCase());
//   }

//   String _getInitials(String? name) {
//     if (name == null || name.trim().isEmpty) return "?";
//     return name.trim()[0].toUpperCase();
//   }

//   Future<void> _pickAndUploadImage(
//     String key,
//     Map<String, dynamic> tempState,
//     void Function(void Function()) setModalState,
//   ) async {
//     final picker = ImagePicker();

//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);

//     if (pickedFile == null) return;

//     final file = File(pickedFile.path);

//     try {
//       final fileName = DateTime.now().millisecondsSinceEpoch.toString();

//       final supabase = Supabase.instance.client;

//       // ⬆️ Upload to "cover_photo" bucket
//       await supabase.storage.from('cover_photos').upload(fileName, file);

//       // 🔗 Get public URL
//       final imageUrl = supabase.storage
//           .from('cover_photos')
//           .getPublicUrl(fileName);

//       // 💾 Save in state
//       setModalState(() {
//         tempState[key] = imageUrl;
//       });
//     } catch (e) {
//       print("Upload error: $e");
//     }
//   }

//   // --- DELETE LOGIC ---
//   Future<void> _deleteProfile() async {
//     final bool? confirm = await showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("Delete Profile?"),
//         content: const Text("This action is permanent and cannot be undone."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(ctx, false),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () => Navigator.pop(ctx, true),
//             child: const Text("Delete", style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await supabase.from('profiles').delete().eq('id', profile['id']);
//         if (mounted) {
//           Navigator.pop(context);
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Profile deleted"),
//               backgroundColor: Colors.redAccent,
//             ),
//           );
//         }
//       } catch (e) {
//         debugPrint("Delete error: $e");
//       }
//     }
//   }

//   // --- DYNAMIC INPUT BUILDER ---
//   Widget _buildEditField(
//     String key,
//     dynamic value,
//     Map<String, dynamic> tempState,
//     StateSetter setModalState,
//   ) {
//     String label = key.replaceAll('_', ' ').toUpperCase();
//     String valStr = tempState[key]?.toString() ?? "";

//     // 1. Dropdown for Titles
//     if (key.toLowerCase().contains('title') ||
//         valStr.toLowerCase() == 'mr' ||
//         valStr.toLowerCase() == 'mrs') {
//       const options = ['Mr', 'Mrs', 'Ms', 'Dr', 'Prof'];
//       String currentVal = options.firstWhere(
//         (opt) => opt.toLowerCase() == valStr.toLowerCase(),
//         orElse: () => options[0],
//       );

//       return _fieldWrapper(
//         label,
//         DropdownButtonFormField<String>(
//           value: currentVal,
//           items: options
//               .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
//               .toList(),
//           onChanged: (val) => setModalState(() => tempState[key] = val),
//           decoration: _inputDecoration(),
//         ),
//       );
//     }

//     // 2. Dropdown for TRUE / FALSE
//     if (value is bool ||
//         valStr.toLowerCase() == 'true' ||
//         valStr.toLowerCase() == 'false') {
//       const boolOptions = ['TRUE', 'FALSE'];
//       String currentBool = valStr.toUpperCase() == 'TRUE' ? 'TRUE' : 'FALSE';

//       return _fieldWrapper(
//         label,
//         DropdownButtonFormField<String>(
//           value: currentBool,
//           items: boolOptions
//               .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
//               .toList(),
//           onChanged: (val) =>
//               setModalState(() => tempState[key] = (val == 'TRUE')),
//           decoration: _inputDecoration(),
//         ),
//       );
//     }

//     // 3. Logic for Cover Image (URL Input with Preview)
//     if (key.toLowerCase() == 'cover_image') {
//       return _fieldWrapper(
//         label,
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (tempState[key] != null &&
//                 tempState[key].toString().startsWith('http'))
//               Container(
//                 height: 100,
//                 width: double.infinity,
//                 margin: const EdgeInsets.only(bottom: 10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   image: DecorationImage(
//                     image: NetworkImage(tempState[key]),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),

//             ElevatedButton.icon(
//               onPressed: () async {
//                 await _pickAndUploadImage(key, tempState, setModalState);
//               },
//               icon: const Icon(Icons.upload),
//               label: const Text("Upload Cover Image"),
//             ),
//           ],
//         ),
//       );
//     }

//     // 4. Logic for Strict Numbers
//     bool isNumericType = value is num || double.tryParse(valStr) != null;
//     bool isDigitOnlyField =
//         key.toLowerCase().contains('mobile') ||
//         key.toLowerCase().contains('phone') ||
//         key.toLowerCase().contains('whatsapp') ||
//         key.toLowerCase().contains('landline') ||
//         key.toLowerCase().contains('pincode') ||
//         key.toLowerCase().contains('code');

//     return _fieldWrapper(
//       label,
//       TextFormField(
//         initialValue: valStr,
//         keyboardType: (isNumericType || isDigitOnlyField)
//             ? TextInputType.number
//             : TextInputType.text,
//         inputFormatters: isDigitOnlyField
//             ? [FilteringTextInputFormatter.digitsOnly]
//             : null,
//         onChanged: (text) {
//           if (isNumericType) {
//             tempState[key] = text.isEmpty ? null : (num.tryParse(text) ?? text);
//           } else {
//             tempState[key] = text.isEmpty ? null : text;
//           }
//         },
//         decoration: _inputDecoration(),
//       ),
//     );
//   }

//   Widget _fieldWrapper(String label, Widget child) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//               color: Colors.blueGrey,
//             ),
//           ),
//           const SizedBox(height: 8),
//           child,
//         ],
//       ),
//     );
//   }

//   InputDecoration _inputDecoration() {
//     return InputDecoration(
//       filled: true,
//       fillColor: Colors.grey[100],
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//     );
//   }

//   void _showEditSheet() {
//     Map<String, dynamic> tempState = Map<String, dynamic>.from(profile);
//     final editableKeys = profile.keys
//         .where((k) => !_isForbiddenField(k))
//         .toList();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setModalState) => Container(
//           height: MediaQuery.of(context).size.height * 0.85,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 margin: const EdgeInsets.only(top: 12),
//                 height: 5,
//                 width: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Edit Profile",
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => Navigator.pop(context),
//                       icon: const Icon(Icons.close_rounded),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Form(
//                   key: _formKey,
//                   child: ListView(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     children: editableKeys
//                         .map(
//                           (k) => _buildEditField(
//                             k,
//                             profile[k],
//                             tempState,
//                             setModalState,
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 55,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blueAccent,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     onPressed: () async {
//                       try {
//                         await supabase
//                             .from('profiles')
//                             .update({
//                               ...tempState,

//                               // 👇 ensure correct column mapping
//                               'cover_image': tempState['cover_image'],
//                             })
//                             .eq('id', profile['id']);

//                         setState(() => profile = tempState);

//                         if (mounted) Navigator.pop(context);

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Profile Updated"),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       } catch (e) {
//                         debugPrint("Update error: $e");
//                       }
//                     },
//                     child: const Text(
//                       "Save Changes",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.transparent,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             color: Color.fromARGB(255, 236, 4, 4),
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             onPressed: _deleteProfile,
//             icon: const Icon(
//               Icons.delete_outline_rounded,
//               color: Color.fromARGB(255, 191, 8, 8),
//             ),
//           ),
//           const SizedBox(width: 10),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Header with Cover Image
//             Stack(
//               alignment: Alignment.bottomCenter,
//               clipBehavior: Clip.none,
//               children: [
//                 Container(
//                   height: 220,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.blueAccent.withOpacity(0.1),
//                     image:
//                         profile['cover_image'] != null &&
//                             profile['cover_image'].toString().startsWith('http')
//                         ? DecorationImage(
//                             image: NetworkImage(profile['cover_image']),
//                             fit: BoxFit.cover,
//                           )
//                         : null,
//                   ),
//                 ),
//                 Positioned(
//                   bottom: -40,
//                   child: Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                     ),
//                     child: CircleAvatar(
//                       radius: 45,
//                       backgroundColor: Colors.blueAccent,
//                       child: Text(
//                         _getInitials(profile['person_name']),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 55),

//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Column(
//                 children: [
//                   Text(
//                     profile['person_name'] ?? "No Name",
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // DISPLAY ALL FIELDS (Including cover_image)
//                   ...profile.entries.where((e) => !_isForbiddenField(e.key)).map((
//                     e,
//                   ) {
//                     final bool isImageUrl =
//                         e.value != null &&
//                         e.value.toString().startsWith('http');

//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   e.key.replaceAll('_', ' ').toUpperCase(),
//                                   style: const TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.blueGrey,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   "${e.value ?? '—'}",
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           // If it's the cover image or any URL, show a tiny preview on the right
//                           if (isImageUrl)
//                             ClipRRect(
//                               borderRadius: BorderRadius.circular(8),
//                               child: Image.network(
//                                 e.value,
//                                 width: 50,
//                                 height: 50,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) =>
//                                     const Icon(
//                                       Icons.broken_image,
//                                       color: Colors.grey,
//                                     ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     );
//                   }),
//                   const SizedBox(height: 100),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         backgroundColor: Colors.black,
//         onPressed: _showEditSheet,
//         label: const Text(
//           "Edit Profile",
//           style: TextStyle(color: Colors.white),
//         ),
//         icon: const Icon(Icons.edit_note, color: Colors.white),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDetailScreen extends StatefulWidget {
  final Map<dynamic, dynamic> profile;
  const ProfileDetailScreen({super.key, required this.profile});

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late Map<String, dynamic> profile;
  final SupabaseClient supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    profile = Map<String, dynamic>.from(widget.profile);
  }

  bool _isForbiddenField(String key) {
    const forbidden = [
      'id',
      'created_at',
      'user_type',
      'profile_image',
      'updated_at',
      'auth_id',
      'role',
      'views',
      'business_address',
    ];
    return forbidden.contains(key.toLowerCase());
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "?";
    return name.trim()[0].toUpperCase();
  }

  // --- DELETE LOGIC ---
  Future<void> _deleteProfile() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Profile?"),
        content: const Text("This action is permanent and cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase.from('profiles').delete().eq('id', profile['id']);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Profile deleted"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } catch (e) {
        debugPrint("Delete error: $e");
      }
    }
  }

  // --- DYNAMIC INPUT BUILDER ---
  Widget _buildEditField(
    String key,
    dynamic value,
    Map<String, dynamic> tempState,
    StateSetter setModalState,
  ) {
    String label = key.replaceAll('_', ' ').toUpperCase();
    String valStr = tempState[key]?.toString() ?? "";

    // 1. Dropdown for Titles
    if (key.toLowerCase().contains('title') ||
        valStr.toLowerCase() == 'mr' ||
        valStr.toLowerCase() == 'mrs') {
      const options = ['Mr', 'Mrs', 'Ms', 'Dr', 'Prof'];
      String currentVal = options.firstWhere(
        (opt) => opt.toLowerCase() == valStr.toLowerCase(),
        orElse: () => options[0],
      );

      return _fieldWrapper(
        label,
        DropdownButtonFormField<String>(
          value: currentVal,
          items: options
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: (val) => setModalState(() => tempState[key] = val),
          decoration: _inputDecoration(),
        ),
      );
    }

    // 2. Dropdown for TRUE / FALSE
    if (value is bool ||
        valStr.toLowerCase() == 'true' ||
        valStr.toLowerCase() == 'false') {
      const boolOptions = ['TRUE', 'FALSE'];
      String currentBool = valStr.toUpperCase() == 'TRUE' ? 'TRUE' : 'FALSE';

      return _fieldWrapper(
        label,
        DropdownButtonFormField<String>(
          value: currentBool,
          items: boolOptions
              .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
              .toList(),
          onChanged: (val) =>
              setModalState(() => tempState[key] = (val == 'TRUE')),
          decoration: _inputDecoration(),
        ),
      );
    }

    // 3. Logic for Cover Image (URL Input with Preview)
    if (key.toLowerCase() == 'cover_image') {
      return _fieldWrapper(
        label,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (valStr.isNotEmpty && valStr.startsWith('http'))
              Container(
                height: 100,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(valStr),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            TextFormField(
              initialValue: valStr,
              onChanged: (text) => setModalState(
                () => tempState[key] = text.isEmpty ? null : text,
              ),
              decoration: _inputDecoration().copyWith(
                hintText: "Enter Image URL",
              ),
            ),
          ],
        ),
      );
    }

    // 4. Logic for Strict Numbers
    bool isNumericType = value is num || double.tryParse(valStr) != null;
    bool isDigitOnlyField =
        key.toLowerCase().contains('mobile') ||
        key.toLowerCase().contains('phone') ||
        key.toLowerCase().contains('whatsapp') ||
        key.toLowerCase().contains('landline') ||
        key.toLowerCase().contains('pincode') ||
        key.toLowerCase().contains('code');

    return _fieldWrapper(
      label,
      TextFormField(
        initialValue: valStr,
        keyboardType: (isNumericType || isDigitOnlyField)
            ? TextInputType.number
            : TextInputType.text,
        inputFormatters: isDigitOnlyField
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        onChanged: (text) {
          if (isNumericType) {
            tempState[key] = text.isEmpty ? null : (num.tryParse(text) ?? text);
          } else {
            tempState[key] = text.isEmpty ? null : text;
          }
        },
        decoration: _inputDecoration(),
      ),
    );
  }

  Widget _fieldWrapper(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void _showEditSheet() {
    Map<String, dynamic> tempState = Map<String, dynamic>.from(profile);
    final editableKeys = profile.keys
        .where((k) => !_isForbiddenField(k))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: editableKeys
                        .map(
                          (k) => _buildEditField(
                            k,
                            profile[k],
                            tempState,
                            setModalState,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await supabase
                            .from('profiles')
                            .update(tempState)
                            .eq('id', profile['id']);
                        setState(() => profile = tempState);
                        if (mounted) Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profile Updated"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        debugPrint("Update error: $e");
                      }
                    },
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromARGB(255, 236, 4, 4),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: _deleteProfile,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color.fromARGB(255, 191, 8, 8),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Cover Image
            Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    image:
                        profile['cover_image'] != null &&
                            profile['cover_image'].toString().startsWith('http')
                        ? DecorationImage(
                            image: NetworkImage(profile['cover_image']),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: -40,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        _getInitials(profile['person_name']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 55),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    profile['person_name'] ?? "No Name",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // DISPLAY ALL FIELDS (Including cover_image)
                  ...profile.entries.where((e) => !_isForbiddenField(e.key)).map((
                    e,
                  ) {
                    final bool isImageUrl =
                        e.value != null &&
                        e.value.toString().startsWith('http');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.key.replaceAll('_', ' ').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${e.value ?? '—'}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // If it's the cover image or any URL, show a tiny preview on the right
                          if (isImageUrl)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                e.value,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: _showEditSheet,
        label: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.edit_note, color: Colors.white),
      ),
    );
  }
}
