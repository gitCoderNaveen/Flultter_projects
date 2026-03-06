import 'package:celfonephonebookapp/features/subscription/controller/subscription_controller.dart';
import 'package:celfonephonebookapp/features/subscription/model/subscription_plan.dart';
import 'package:flutter/material.dart';

// Helper to capitalize first letter
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
    List<String> features = controller.allUniqueFeatures;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontFamily: 'sans-serif', letterSpacing: 0.5),
            children: [
              TextSpan(
                text: 'Cel',
                style: TextStyle(
                  color: Color(0xFFE31E24),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: 'fon',
                style: TextStyle(
                  color: Color(0xFF0072BC),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: ' BOOK ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextSpan(
                text: 'TARIFF',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black.withOpacity(0.1),
                  width: 1.5,
                ),
              ),

              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child: DataTable(
                  columnSpacing: 25,
                  headingRowHeight: 130,
                  horizontalMargin: 15,
                  border: TableBorder.all(
                    color: Colors.black.withOpacity(0.05),
                    width: 1,
                  ),

                  columns: [
                    const DataColumn(
                      label: Text(
                        "FEATURES",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    ...plans.map(
                      (plan) => DataColumn(
                        label: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              plan.title.split(" ")[0],
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

                            const SizedBox(height: 4),

                            if (plan.hasDiscount)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
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

                            const SizedBox(height: 2),

                            Text(
                              plan.paLabel,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  rows: features.map((feature) {
                    return DataRow(
                      color: WidgetStateProperty.all(
                        controller.getRowColor(feature),
                      ),

                      cells: [
                        DataCell(
                          Text(
                            feature.capitalize(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        ...plans.map((plan) {
                          bool hasFeature = plan.features.contains(feature);

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
                                    fontSize: 15,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            );
                          }

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
                                      size: 16,
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

            const SizedBox(height: 20),

            const Text(
              "SCROLL HORIZONTALLY TO COMPARE PLANS →",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
