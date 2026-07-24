import 'package:celfonephonebookapp/core/widgets/section_title.dart';
import 'package:celfonephonebookapp/features/home/service/quick_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../theme/app_radius.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_spacing.dart';

class QuickActionsSection extends StatelessWidget {

  final List<QuickAction> actions;

  const QuickActionsSection({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        const SectionTitle(
          title: "Quick Access",
        ),

        Padding(

          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),

          child: GridView.builder(

            shrinkWrap: true,

            physics:
                const NeverScrollableScrollPhysics(),

            itemCount: actions.length,

            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(

              crossAxisCount: 4,

              childAspectRatio: .9,

              crossAxisSpacing: 14,

              mainAxisSpacing: 14,
            ),

            itemBuilder: (_, index) {

              final item = actions[index];

              return InkWell(

                borderRadius:
                    BorderRadius.circular(AppRadius.lg),

                onTap: item.onTap,

                child: Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                        BorderRadius.circular(AppRadius.lg),

                    boxShadow: AppShadows.soft,
                  ),

                  child: Column(

                    mainAxisAlignment:
                        MainAxisAlignment.center,

                    children: [

                      Container(

                        width: 56,

                        height: 56,

                        decoration: BoxDecoration(

                          shape: BoxShape.circle,

                          color: item.color.withOpacity(.12),
                        ),

                        child: Icon(
                          item.icon,
                          color: item.color,
                          size: 28,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(

                        item.title,

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fade()
                  .scale(
                    delay:
                        Duration(milliseconds: index * 80),
                  );
            },
          ),
        ),
      ],
    );
  }
}