import 'package:flutter/material.dart';

import '../controller/profile_controller.dart';

class IndividualForm extends StatelessWidget {
  final ProfileController controller;

  const IndividualForm({super.key, required this.controller});

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
              "Individual Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

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

            //------------------------------------------
            // Person Name
            //------------------------------------------
            TextFormField(
              controller: controller.personNameController,
              decoration: const InputDecoration(
                labelText: "Person Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),

            //------------------------------------------
            // Profession
            //------------------------------------------
            TextFormField(
              controller: controller.professionController,
              decoration: const InputDecoration(
                labelText: "Profession",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.work),
              ),
            ),

            const SizedBox(height: 16),

            //------------------------------------------
            // Address
            //------------------------------------------
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

            const SizedBox(height: 16),

            //------------------------------------------
            // Mobile
            //------------------------------------------
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

            //------------------------------------------
            // WhatsApp
            //------------------------------------------
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

            const SizedBox(height: 10),

            //------------------------------------------
            // Email
            //------------------------------------------
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

            //------------------------------------------
            // Landline Code
            //------------------------------------------
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: controller.landlineCodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "STD Code",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  flex: 5,
                  child: TextFormField(
                    controller: controller.landlineController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Landline",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            //------------------------------------------
            // City
            //------------------------------------------
            TextFormField(
              controller: controller.cityController,
              decoration: const InputDecoration(
                labelText: "City",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
            ),

            const SizedBox(height: 16),

            //------------------------------------------
            // Pincode
            //------------------------------------------
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
