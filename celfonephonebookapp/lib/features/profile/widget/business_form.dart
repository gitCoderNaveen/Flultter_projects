import 'package:flutter/material.dart';

import '../controller/profile_controller.dart';

class BusinessForm extends StatelessWidget {
  final ProfileController controller;

  const BusinessForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Business Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            //----------------------------------
            // Owner Name
            //----------------------------------
            TextFormField(
              controller: controller.personNameController,
              decoration: const InputDecoration(
                labelText: "Owner Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),
            //------------------------------------------
            // Prefix
            //------------------------------------------
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Prefix",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    _buildPrefixRadio(controller, "Mr"),
                    _buildPrefixRadio(controller, "Ms"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            //----------------------------------
            // Business Name
            //----------------------------------
            TextFormField(
              controller: controller.businessNameController,
              decoration: const InputDecoration(
                labelText: "Business Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),

            const SizedBox(height: 20),

            //----------------------------------
            // KEYWORDS
            //----------------------------------
            const Text(
              "Products / Services",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.keywordController,
                    decoration: const InputDecoration(
                      hintText: "Enter Keyword",
                      border: OutlineInputBorder(),
                    ),
                    onFieldSubmitted: (_) {
                      controller.addKeyword();
                    },
                  ),
                ),

                const SizedBox(width: 10),

                FilledButton(
                  onPressed: () {
                    controller.addKeyword();
                  },
                  child: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(controller.keywords.length, (index) {
                final keyword = controller.keywords[index];

                return Chip(
                  label: Text(keyword),

                  deleteIcon: const Icon(Icons.close),

                  onDeleted: () {
                    controller.removeKeyword(index);
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            //----------------------------------
            // DESCRIPTION
            //----------------------------------
            TextFormField(
              controller: controller.descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 20),

            //----------------------------------
            // ADDRESS
            //----------------------------------
            TextFormField(
              controller: controller.addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.home),
              ),
            ),

            const SizedBox(height: 20),

            //----------------------------------
            // MOBILE
            //----------------------------------
            TextFormField(
              controller: controller.mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Mobile Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              onChanged: (value) {
                if (controller.sameAsMobile) {
                  controller.whatsappController.text = value;
                }
              },
            ),

            const SizedBox(height: 16),

            //----------------------------------
            // WHATSAPP
            //----------------------------------
            TextFormField(
              controller: controller.whatsappController,
              enabled: !controller.sameAsMobile,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "WhatsApp Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.chat),
              ),
            ),

            CheckboxListTile(
              value: controller.sameAsMobile,
              contentPadding: EdgeInsets.zero,
              title: const Text("Same as Mobile Number"),
              onChanged: (value) {
                controller.toggleSameAsMobile(value ?? false);
              },
            ),

            const SizedBox(height: 12),

            //----------------------------------
            // EMAIL
            //----------------------------------
            TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 16),

            //----------------------------------
            // LANDLINE
            //----------------------------------
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: controller.landlineCodeController,
                    decoration: const InputDecoration(
                      labelText: "STD",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: controller.landlineController,
                    decoration: const InputDecoration(
                      labelText: "Landline",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            //----------------------------------
            // WEBSITE
            //----------------------------------
            TextFormField(
              controller: controller.websiteController,
              decoration: const InputDecoration(
                labelText: "Website",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
            ),

            const SizedBox(height: 16),

            //----------------------------------
            // PROMO CODE
            //----------------------------------
            TextFormField(
              controller: controller.promoCodeController,
              decoration: const InputDecoration(
                labelText: "Promo Code",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.discount),
              ),
            ),

            const SizedBox(height: 16),

            //----------------------------------
            // CITY
            //----------------------------------
            TextFormField(
              controller: controller.cityController,
              decoration: const InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),

            const SizedBox(height: 16),

            //----------------------------------
            // PINCODE
            //----------------------------------
            TextFormField(
              controller: controller.pincodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Pincode",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin_drop),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrefixRadio(ProfileController controller, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: controller.selectedPrefix,
          onChanged: (val) {
            if (val != null) {
              controller.setPrefix(val);
            }
          },
        ),
        Text(value),
      ],
    );
  }
}
