import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/categorywise_pro_controller.dart';

class CategorywiseResultPage extends StatelessWidget {
  const CategorywiseResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Provider.of<CategorywiseProController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(title: const Text("Search Results")),

      body: Column(
        children: [
          /// HEADER
          Padding(
            padding: const EdgeInsets.all(15),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Records : ${c.searchResults.length}"),

                    Text("Selected : ${c.selectedIndices.length}"),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _greenButton(
                      text: "Send Sms",
                      onPressed: c.selectedIndices.isEmpty ? null : c.sendSMS,
                    ),

                    const SizedBox(width: 10),

                    _greenButton(text: "Clear", onPressed: c.clearAll),
                  ],
                ),
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: ListView.builder(
              itemCount: c.searchResults.length,

              itemBuilder: (_, index) {
                final item = c.searchResults[index];

                final selected = c.selectedIndices.contains(index);

                final isSent = c.sentBusinessIds.contains(item.id);

                return GestureDetector(
                  onTap: isSent ? null : () => c.toggleSelection(index),

                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),

                    padding: const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(3, 5)),
                      ],
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.businessName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(item.mobileNumber),
                          ],
                        ),

                        Container(
                          width: 24,
                          height: 24,

                          decoration: BoxDecoration(
                            border: Border.all(),
                            color: selected ? Colors.green : Colors.transparent,
                          ),

                          child: selected
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(bottom: 20),

            child: _greenButton(
              text: "Send Sms",
              onPressed: c.selectedIndices.isEmpty ? null : c.sendSMS,
            ),
          ),
        ],
      ),
    );
  }

  Widget _greenButton({
    required String text,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),

      onPressed: onPressed,

      child: Text(text),
    );
  }
}
