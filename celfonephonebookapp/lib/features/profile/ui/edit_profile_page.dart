import 'package:celfonephonebookapp/features/profile/widget/business_form.dart';
import 'package:celfonephonebookapp/features/profile/widget/individual_form.dart';
import 'package:celfonephonebookapp/features/profile/widget/product_image_picker.dart';
import 'package:celfonephonebookapp/features/profile/widget/profile_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/profile_controller.dart';
import '../repository/profile_repository.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ProfileController(
            repository: ProfileRepository(),
          )..init(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatelessWidget {
  const _EditProfileView();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: const Color(0xffF5F7FA),

          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: const Text(
              "Edit Profile",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          body: controller.loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                      children: [

                        //----------------------------------
                        // Dashboard Cards
                        //----------------------------------

                        // Row(
                        //   children: [

                        //     Expanded(
                        //       child: _dashboardCard(
                        //         title: "Views",
                        //         value:
                        //             controller.viewsCount
                        //                 .toString(),
                        //         icon: Icons.visibility,
                        //         color: Colors.blue,
                        //       ),
                        //     ),

                        //     const SizedBox(width: 12),

                        //     Expanded(
                        //       child: _dashboardCard(
                        //         title: "Leads",
                        //         value:
                        //             controller.leadsCount
                        //                 .toString(),
                        //         icon: Icons.people,
                        //         color: Colors.green,
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        const SizedBox(height: 20),

                        //----------------------------------
                        // Profile Image
                        //----------------------------------

                        ProfileImagePicker(
                          controller: controller,
                        ),

                        const SizedBox(height: 24),

                        //----------------------------------
                        // Profile Type
                        //----------------------------------

                        Card(
                          elevation: 2,
                          child: Padding(
                            padding:
                                const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [

                                const Text(
                                  "Profile Type",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                SegmentedButton<bool>(
                                  segments: const [

                                    ButtonSegment(
                                      value: false,
                                      icon: Icon(
                                        Icons.person,
                                      ),
                                      label: Text(
                                        "Individual",
                                      ),
                                    ),

                                    ButtonSegment(
                                      value: true,
                                      icon: Icon(
                                        Icons.business,
                                      ),
                                      label: Text(
                                        "Business",
                                      ),
                                    ),
                                  ],

                                  selected: {
                                    controller
                                        .isBusiness,
                                  },

                                  onSelectionChanged:
                                      (value) {
                                    controller
                                        .toggleBusiness(
                                      value.first,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        //----------------------------------
                        // Forms
                        //----------------------------------

                        controller.isBusiness
                            ? BusinessForm(
                                controller:
                                    controller,
                              )
                            : IndividualForm(
                                controller:
                                    controller,
                              ),

                        const SizedBox(height: 20),

                        //----------------------------------
                        // Product Images
                        //----------------------------------

                        // if (controller.isBusiness)
                        //   ProductImagePicker(
                        //     controller:
                        //         controller,
                        //   ),

                        const SizedBox(height: 30),

                        //----------------------------------
                        // Save Button
                        //----------------------------------

                        SizedBox(
                          height: 55,
                          child: FilledButton.icon(
                            onPressed:
                                controller.saving
                                    ? null
                                    : () async {
                                        final success =
                                            await controller
                                                .saveProfile();

                                        if (!context
                                            .mounted) {
                                          return;
                                        }

                                        if (success) {
                                          ScaffoldMessenger.of(
                                                  context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text(
                                                "Profile Updated Successfully",
                                              ),
                                            ),
                                          );

                                          Navigator.pop(
                                            context,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                                  context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text(
                                                "Unable to Save Profile",
                                              ),
                                            ),
                                          );
                                        }
                                      },

                            icon: controller.saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                      color: Color(0xFF2E8CA8),
                                    ),
                                  )
                                : const Icon(
                                    Icons.save,
                                  ),

                            label: Text(
                              controller.saving
                                  ? "Saving..."
                                  : "Save Profile",
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 20,
        ),
        child: Column(
          children: [

            CircleAvatar(
              radius: 22,
              backgroundColor:
                  color.withOpacity(.12),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}