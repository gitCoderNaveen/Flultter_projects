import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/nearbypromotion_controller.dart';
import '../model/nearbypromotion_model.dart';
import 'search_result_page.dart';

class NearbyPromotionPage extends StatefulWidget {
  const NearbyPromotionPage({super.key});

  @override
  State<NearbyPromotionPage> createState() => _NearbyPromotionPageState();
}

class _NearbyPromotionPageState extends State<NearbyPromotionPage>
    with SingleTickerProviderStateMixin {
  final controller = NearbyPromotionController();

  final messageController = TextEditingController(
    text:
        "I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Call Me.",
  );

  final pincodeController = TextEditingController();

  String category = "Gents";

  bool loading = false;
  bool showInstructions = false;

  Future<void> search() async {
    FocusScope.of(context).unfocus();

    if (messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a promotion message")),
      );
      return;
    }

    if (pincodeController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid 6 digit pincode")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final profiles = await controller.search(
        pincodeController.text,
        category,
      );

      setState(() => loading = false);

      if (profiles.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text("No records found for this pincode."),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SearchResultsPage(
            profiles: profiles,
            message: messageController.text,
            controller: controller,
          ),
        ),
      );
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xffF5F8FC),
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          /// BLUE HEADER
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff0A7CFF), Color(0xff25C4FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
          ),

          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    /// TOP BAR
                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 18,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 12),
                            ],
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.poppins(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                              children: const [
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

                        const Spacer(),

                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Connects For Growth",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// HOW TO USE CARD
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.06),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              setState(() {
                                showInstructions = !showInstructions;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 52,
                                    width: 52,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: const Icon(
                                      Icons.campaign,
                                      color: Color(0xff0A7CFF),
                                    ),
                                  ),

                                  const SizedBox(width: 15),

                                  Expanded(
                                    child: Text(
                                      "How to Use Nearby Promotion",
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),

                                  AnimatedRotation(
                                    turns: showInstructions ? .5 : 0,
                                    duration: const Duration(milliseconds: 250),
                                    child: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),

                            crossFadeState: showInstructions
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,

                            firstChild: const SizedBox(),

                            secondChild: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(
                                left: 18,
                                right: 18,
                                bottom: 18,
                              ),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  instructionTile("Edit your promotional SMS."),

                                  instructionTile("Choose recipient type."),

                                  instructionTile(
                                    "Enter the destination pincode.",
                                  ),

                                  instructionTile(
                                    "Search and send SMS in batches.",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// EDIT TEXT TITLE
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_note,
                            color: Colors.deepPurple,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          "Promotion Message",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// MESSAGE BOX
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: messageController,
                            maxLines: 6,
                            style: GoogleFonts.poppins(fontSize: 15),
                            decoration: InputDecoration(
                              hintText: "Type your promotion message...",
                              hintStyle: GoogleFonts.poppins(),
                              contentPadding: const EdgeInsets.all(20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),

                          Divider(height: 1, color: Colors.grey.shade200),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.sms,
                                  color: Colors.green,
                                  size: 18,
                                ),

                                const SizedBox(width: 8),

                                Text(
                                  "${messageController.text.length} Characters",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                const Spacer(),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    "${((messageController.text.length / 145).ceil()).clamp(1, 2)} SMS",
                                    style: GoogleFonts.poppins(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// RECIPIENT TYPE
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.people_alt_rounded,
                            color: Colors.orange,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          "Select Recipient",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: CategoryCard(
                            title: "Gents",
                            icon: Icons.man,
                            color: Colors.blue,
                            selected: category == "Gents",
                            onTap: () {
                              setState(() {
                                category = "Gents";
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: CategoryCard(
                            title: "Ladies",
                            icon: Icons.woman,
                            color: Colors.pink,
                            selected: category == "Ladies",
                            onTap: () {
                              setState(() {
                                category = "Ladies";
                              });
                            },
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: CategoryCard(
                            title: "Firms",
                            icon: Icons.business_center_rounded,
                            color: Colors.green,
                            selected: category == "Firms",
                            onTap: () {
                              setState(() {
                                category = "Firms";
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),

                    /// PINCODE TITLE
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          "Target Pincode",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.05),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: pincodeController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "Enter 6 digit pincode",

                          hintStyle: GoogleFonts.poppins(),

                          prefixIcon: Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.pin_drop,
                              color: Colors.red,
                            ),
                          ),

                          suffixIcon: pincodeController.text.length == 6
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),

                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 20,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),

                    const SizedBox(height: 35),

                    /// SEARCH BUTTON
                    SizedBox(
                      width: width * .85,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: loading ? null : search,

                        style: ElevatedButton.styleFrom(
                          elevation: 8,
                          backgroundColor: const Color(0xff17A34A),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),

                        child: loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.search,
                                    size: 28,
                                    color: Colors.white,
                                  ),

                                  const SizedBox(width: 10),

                                  Text(
                                    "Search Nearby",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          if (loading)
            Container(
              color: Colors.black38,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

///------------------------------------------------------------
/// CATEGORY CARD
///------------------------------------------------------------

class CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(.08) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? color.withOpacity(.18)
                  : Colors.black.withOpacity(.05),
              blurRadius: selected ? 18 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                color: selected ? color.withOpacity(.18) : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 34),
            ),

            const SizedBox(height: 14),

            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: selected ? color : Colors.black87,
              ),
            ),

            const SizedBox(height: 10),

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: selected ? 34 : 0,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

///------------------------------------------------------------
/// INSTRUCTION TILE
///------------------------------------------------------------

Widget instructionTile(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          height: 24,
          width: 24,
          decoration: const BoxDecoration(
            color: Color(0xff0A7CFF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 16, color: Colors.white),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 15,
              height: 1.45,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    ),
  );
}
