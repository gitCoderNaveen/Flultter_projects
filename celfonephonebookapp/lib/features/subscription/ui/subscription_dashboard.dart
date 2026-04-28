import 'package:celfonephonebookapp/features/subscription/controller/subscription_controller.dart';
import 'package:celfonephonebookapp/features/subscription/model/subscription_plan.dart';
import 'package:flutter/material.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class SubscriptionDashboard extends StatefulWidget {
  const SubscriptionDashboard({super.key});

  @override
  State<SubscriptionDashboard> createState() => _SubscriptionDashboardState();
}

class _SubscriptionDashboardState extends State<SubscriptionDashboard> {
  final SubscriptionController controller = SubscriptionController();

  @override
  Widget build(BuildContext context) {
    List<SubscriptionPlan> plans = controller.plans;

    
    List<String> rawFeatures = controller.allUniqueFeatures
        .where((f) => !f.toLowerCase().contains("whatsapp"))
        .toList();

    // Logic to move "Position" to the top
    List<String> sortedFeatures = [];
    if (rawFeatures.contains("Position")) {
      sortedFeatures.add("Position");
      rawFeatures.remove("Position");
    }
    sortedFeatures.addAll(rawFeatures);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'BRANDING Ads TARIFF',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernTable(plans, sortedFeatures),
            const SizedBox(height: 25),
            _buildFullDescriptionSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildModernTable(
    List<SubscriptionPlan> plans,
    List<String> features,
  ) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 25,
                headingRowHeight: 140,
                horizontalMargin: 15,
                headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                border: TableBorder.all(
                  color: Colors.black.withOpacity(0.03),
                  width: 1,
                ),
                columns: [
                  const DataColumn(
                    label: Text(
                      'FEATURES',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  ...plans.map(
                    (plan) => DataColumn(label: _buildPlanHeader(plan)),
                  ),
                ],
                rows: features.map((feature) {
                  return DataRow(
                    color: WidgetStateProperty.all(
                      controller.getRowColor(feature).withOpacity(0.15),
                    ),
                    cells: [
                      DataCell(
                        Text(
                          feature.capitalize(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ...plans.map((plan) {
                        bool hasFeature = plan.features.contains(feature);

                        // "Position" feature-ku special text formatting
                        if (feature == "Position") {
                          return DataCell(
                            Center(
                              child: Text(
                                plan.positionText,
                                style: TextStyle(
                                  color: plan.positionText == "--"
                                      ? Colors.black26
                                      : plan.color,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                        }

                        // Matha features-ku check icon or remove icon
                        return DataCell(
                          Center(
                            child: hasFeature
                                ? Icon(
                                    Icons.check_circle,
                                    size: 20,
                                    color: plan.color,
                                  )
                                : const Icon(
                                    Icons.remove,
                                    size: 14,
                                    color: Colors.black12,
                                  ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "SCROLL HORIZONTALLY TO COMPARE →",
          style: TextStyle(
            color: Colors.black45,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanHeader(SubscriptionPlan plan) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          plan.title.split(' ')[0],
          style: TextStyle(
            color: plan.color,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          plan.pmLabel,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (plan.hasDiscount)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "SAVE 20%",
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          plan.paLabel,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildFullDescriptionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            textAlign: TextAlign.justify,
            text: const TextSpan(
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text: " *Free: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                TextSpan(
                  text:
                      "In this Celfon book every mobile user is listed free. Full address, all communication (mobile, LL, email, web) given. For business and professionals listed free up to 3 categories. Free registered firms are displayed free under respective search results in ",
                ),
                TextSpan(
                  text: "black colour.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          RichText(
            textAlign: TextAlign.justify,
            text: const TextSpan(
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text: "+Business: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                TextSpan(
                  text:
                      "For business firms needing outstanding visibility can select any one of the branding ads: ",
                ),
                TextSpan(
                  text:
                      "Premium Listings (Top 2), Priority Listing (Top 5), or Business Listing (Top 10) ",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      "for the category keyword they prefer. The tariff is per one keyword per month or year. They are listed at the top of the search results in ",
                ),
                TextSpan(
                  text: "red / blue / green colour.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
