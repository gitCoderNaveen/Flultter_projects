import 'package:celfonephonebookapp/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/categorywise_pro_controller.dart';
import 'categorywise_result_page.dart';

class CategorywiseProPage extends StatelessWidget {
  const CategorywiseProPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategorywiseProController(),
      child: const _CategorywiseProView(),
    );
  }
}

class _CategorywiseProView extends StatelessWidget {
  const _CategorywiseProView();

  @override
  Widget build(BuildContext context) {
    final c = Provider.of<CategorywiseProController>(context);

    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(title: const _HeaderRow(collapsed: true)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DROPDOWN INSTRUCTION
            _instructionDropdown(),

            const SizedBox(height: 15),

            const Text("Edit Text"),

            const SizedBox(height: 5),

            _textField(controller: c.messageController, maxLines: 4),

            const SizedBox(height: 20),

            const Text("Enter Category"),

            const SizedBox(height: 5),

            categoryAutocomplete(c),

            const SizedBox(height: 30),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),

                onPressed: () async {
                  await c.search();

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: c,
                        child: const CategorywiseResultPage(),
                      ),
                    ),
                  );
                },

                child: const Text("Search", style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= INSTRUCTION DROPDOWN =================

  Widget _instructionDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(2, 3)),
        ],
      ),
      child: ExpansionTile(
        title: const Text(
          "How to use Categorywise Promotion",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: const [
          Padding(
            padding: EdgeInsets.all(15),

            child: Text(
              "Send Text messages to all Mobile Users dealing in a specific product / keyword\n\n"
              "1) First edit / create message to be sent.\n"
              "Minimum 1 Count (145 characters)\n"
              "Maximum 2 counts (290 characters)\n\n"
              "2) Type specific Category / product / keyword\n\n"
              "3) For error free delivery send in batches of 10 each time.",

              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TEXT FIELD =================

  Widget _textField({
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(10),
        ),
      ),
    );
  }

  Widget categoryAutocomplete(CategorywiseProController c) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue value) async {
        if (value.text.trim().isEmpty) {
          return const Iterable<String>.empty();
        }

        /// call your SQL logic
        final results = await c.getSuggestions("keywords", value.text.trim());

        return results;
      },

      displayStringForOption: (option) => option,

      fieldViewBuilder:
          (context, textEditingController, focusNode, onEditingComplete) {
            /// initialize with existing value
            textEditingController.value = c.categoryController.value;

            /// sync changes safely
            textEditingController.addListener(() {
              if (c.categoryController.text != textEditingController.text) {
                c.categoryController.text = textEditingController.text;

                c.categoryController.selection =
                    textEditingController.selection;
              }
            });

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(),
              ),

              child: TextField(
                controller: textEditingController,
                focusNode: focusNode,

                decoration: const InputDecoration(
                  hintText: "Enter Category",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            );
          },

      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,

          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(10),

            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,

                itemCount: options.length,

                itemBuilder: (context, index) {
                  final option = options.elementAt(index);

                  return ListTile(
                    title: Text(option),

                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },

      onSelected: (String selection) {
        c.categoryController.text = selection;

        c.categoryController.selection = TextSelection.collapsed(
          offset: selection.length,
        );
      },
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
