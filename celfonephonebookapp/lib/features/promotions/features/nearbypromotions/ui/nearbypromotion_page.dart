import 'package:celfonephonebookapp/features/promotions/features/nearbypromotions/ui/search_result_page.dart';
import 'package:flutter/material.dart';
import '../controller/nearbypromotion_controller.dart';
import '../model/nearbypromotion_model.dart';

class NearbyPromotionPage extends StatefulWidget {
  const NearbyPromotionPage({super.key});

  @override
  State<NearbyPromotionPage> createState() => _NearbyPromotionPageState();
}

class _NearbyPromotionPageState extends State<NearbyPromotionPage> {
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
    if (pincodeController.text.length != 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Enter valid pincode")));
      return;
    }

    setState(() => loading = true);

    List<NearbyPromotionModel> profiles = await controller.search(
      pincodeController.text,
      category,
    );

    setState(() => loading = false);

    /// OPEN RESULT PAGE WITH ZOOM ANIMATION
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => SearchResultsPage(
          profiles: profiles,
          message: messageController.text,
          controller: controller,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          );
        },
      ),
    );
  }

  Widget buildRadio(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: category,
          onChanged: (v) {
            setState(() => category = v!);
          },
        ),
        Text(value),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const _HeaderRow(collapsed: true)),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  /// HEADER
                  InkWell(
                    onTap: () {
                      setState(() {
                        showInstructions = !showInstructions;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "How to use Nearby Promotion",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          AnimatedRotation(
                            turns: showInstructions ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(Icons.expand_more),
                          ),
                        ],
                      ),
                    ),
                  ),

                  /// BODY
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),

                    crossFadeState: showInstructions
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,

                    firstChild: const SizedBox(),

                    secondChild: Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),

                      child: const Text(
                        "Send Text messages to Mobile Users in desired Pincode Area\n\n"
                        "1) First edit / create message to be sent. Minimum 1 Count (145 characters), Maximum 2 counts (290 characters)\n\n"
                        "2) Select type of Recipient (Males / Females / Business Firms)\n\n"
                        "3) Type Pincode Number of Targetted area for Promotion\n\n"
                        "4) For error free delivery of messages, send in batches of 10 nos. each time",

                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Edit Text",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            const Text(
              "Select Prefix",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            Row(
              children: [
                buildRadio("Gents"),
                buildRadio("Ladies"),
                buildRadio("Firms"),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Enter Pincode",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: pincodeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: loading ? null : search,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Search"),
              ),
            ),
          ],
        ),
      ),
    );
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
