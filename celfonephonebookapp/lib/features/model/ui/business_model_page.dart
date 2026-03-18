import 'package:celfonephonebookapp/features/favorites/controller/favorite_controller.dart';
import 'package:celfonephonebookapp/features/favorites/view/favorite_dialog.dart';
import 'package:celfonephonebookapp/features/model/ui/full_screen_image.dart';
import 'package:flutter/material.dart';
import '../controller/profile_controller.dart';
import '../model/profile_model.dart';
import '../model/product_model.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessModel extends StatefulWidget {
  final String profileId;

  const BusinessModel({super.key, required this.profileId});

  @override
  State<BusinessModel> createState() => _BusinessModelState();
}

class _BusinessModelState extends State<BusinessModel> {
  final controller = ProfileController();

  ProfileModel? profile;
  List<ProductModel> products = [];

  bool showAbout = true;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    profile = await controller.getProfile(widget.profileId);
    products = await controller.getProducts(widget.profileId);

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profile == null) {
      return const Scaffold(body: Center(child: Text("Profile not found")));
    }

    return Scaffold(
      appBar: AppBar(title: _HeaderRow(collapsed: true)),
      body: Column(
        children: [
          /// COVER IMAGE
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FullScreenImage(imageUrl: profile!.coverImage),
                ),
              );
            },
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(profile!.coverImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// PROFILE INFO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,

                  /// Crown on left (Premium badge)
                  leading: profile!.isPrime == true
                      ? Image.asset("images/crown.png", height: 28, width: 28)
                      : null,

                  /// Name (Business or Person)
                  title: Text(
                    profile!.businessName.isNotEmpty
                        ? profile!.businessName
                        : profile!.personName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),

                  subtitle: Text(
                    profile!.keywords,
                    style: const TextStyle(fontSize: 16),
                  ),

                  /// Favorite Button on Right
                  trailing: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => FavoriteDialog(
                          onSelected: (groupName) async {
                            await FavoriteController().addToFavorite(
                              groupName: groupName,
                              businessName: profile!.businessName,
                              personName: profile!.personName,
                              mobileNumber: profile!.mobile,
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Added to favorites"),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.favorite, color: Colors.red, size: 20),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// CONTACT ACTIONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (profile!.mobile.isNotEmpty)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _iconButton(
                                imagePath: 'images/call.png',

                                onTap: () {
                                  launchUrl(
                                    Uri.parse("tel:${profile!.mobile}"),
                                  );
                                },
                              ),

                              const SizedBox(height: 5),

                              const Text(
                                'Mobile',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    // LANDLINE (only if exists)
                    if (profile!.landline.isNotEmpty)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _iconButton(
                            imagePath: 'images/land_line.png',

                            onTap: () {
                              launchUrl(
                                Uri.parse(
                                  "tel:${profile!.landlineCode}${profile!.landline}",
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Landline',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                    /// WHATSAPP (only if mobile exists)
                    if (profile!.mobile.isNotEmpty)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _iconButton(
                            imagePath: "images/whats_app.png",

                            onTap: () {
                              final mobile = profile!.mobile;
                              final msg =
                                  "Hello, I found your profile in the app.";
                              final url =
                                  "https://wa.me/+91$mobile?text=${Uri.encodeComponent(msg)}";
                              launchUrl(Uri.parse(url));
                            },
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'WhatsApp',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    //SMS
                    if (profile!.mobile.isNotEmpty)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _iconButton(
                            imagePath: 'images/sms.png',

                            onTap: () {
                              final msg =
                                  "Hello, I found your profile in the app.";
                              launchUrl(
                                Uri.parse(
                                  "sms:${profile!.mobile}?body=${Uri.encodeComponent(msg)}",
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'SMS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),

                    /// MAIL (only if exists)
                    if (profile!.email.isNotEmpty)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _iconButton(
                            imagePath: 'images/email.png',

                            onTap: () {
                              final msg =
                                  "Hello, I found your profile in the app.";
                              launchUrl(
                                Uri.parse(
                                  "mailto:${profile!.email}?subject=Enquiry&body=${Uri.encodeComponent(msg)}",
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(),

          /// TAB BUTTONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                // Expanded(
                //   child: _tabButton(
                //     title: "About",
                //     selected: showAbout,
                //     onTap: () {
                //       setState(() {
                //         showAbout = true;
                //       });
                //     },
                //   ),
                // ),
                const SizedBox(width: 10),
                // Expanded(
                //   child: _tabButton(
                //     title: "Products",
                //     selected: !showAbout,
                //     onTap: () {
                //       setState(() {
                //         showAbout = false;
                //       });
                //     },
                //   ),
                // ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// TAB CONTENT
          Expanded(
            child: showAbout ? _buildAboutSection() : _buildProductSection(),
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    IconData? icon,
    String? imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: imagePath != null
          ? Image.asset(
              imagePath,
              height: 40, // increased size
              width: 40, // increased size
              fit: BoxFit.contain,
            )
          : Icon(
              icon,
              size: 40, // larger icon
            ),
    );
  }

  Widget _tabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection() {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: Image.network(
              product.image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
            title: Text(product.name),
            subtitle: Text(product.description),
            trailing: Text("₹${product.price}"),
          ),
        );
      },
    );
  }

  Widget _buildAboutSection() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        if (profile!.personName.isNotEmpty)
          _aboutItem(Icons.person, profile!.personName),

        if (profile!.mobile.isNotEmpty)
          _aboutItem(Icons.phone, _formatMobile(profile!.mobile)),
        if (profile!.landline.isNotEmpty)
          _aboutItem(
            Icons.phone_in_talk,
            '${profile!.landlineCode}-${_formatLandline(profile!.landline)}',
          ),

        if (profile!.address.isNotEmpty ||
            profile!.city.isNotEmpty ||
            profile!.pincode.isNotEmpty)
          _aboutItem(
            Icons.location_city,
            "${profile!.address}, ${profile!.city} - ${profile!.pincode}",
          ),

        if (profile!.email.isNotEmpty)
          _aboutItem(Icons.email, _formatEmail(profile!.email)),

        if (profile!.description.isNotEmpty)
          _aboutItem(Icons.description, profile!.description),
      ],
    );
  }

  Widget _aboutItem(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _formatMobile(String mobile) {
    if (mobile.length < 5) return mobile;
    return mobile.substring(0, 5) + " XXXXX";
  }

  String _formatLandline(String landline) {
    if (landline.length < 5) return landline;
    return landline.substring(0, 2) + " XXXXX";
  }

  String _formatEmail(String email) {
    if (email.length < 5) return email;
    return email.substring(0, 6) + " XXXXX";
  }
}

class _HeaderRow extends StatelessWidget {
  final bool collapsed;
  const _HeaderRow({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final color = collapsed ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: "Cel",
                            style: TextStyle(color: Colors.red),
                          ),
                          TextSpan(
                            text: "fon",
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(
                            text: " Book",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    "Connects For Growth",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
