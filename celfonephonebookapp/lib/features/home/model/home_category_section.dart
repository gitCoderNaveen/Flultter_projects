import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/category_item_model.dart';

class HomeCategoriesSection extends StatelessWidget {
  final String title;
  const HomeCategoriesSection({super.key, required this.title});

  // ── B2C Static Categories ──
  static const _b2cCategories = [
    {
      'icon': Icons.local_hospital,
      'label': 'Hospital',
      'c1': Color(0xFFFF6B6B),
      'c2': Color(0xFFFFE66D),
    },
    {
      'icon': Icons.restaurant,

      'label': 'Hotel',
      'c1': Color(0xFFFC5C7D),
      'c2': Color(0xFF6A82FB),
    },
    {
      'icon': Icons.school,
      'label': 'Colleges',
      'c1': Color(0xFF667EEA),
      'c2': Color(0xFF764BA2),
    },
    {
      'icon': Icons.flight,
      'label': 'Travel',
      'c1': Color(0xFFF7971E),
      'c2': Color(0xFFFFD200),
    },
    {
      'icon': Icons.medical_services,
      'label': 'Doctors',
      'c1': Color(0xFF4ECDC4),
      'c2': Color(0xFF44A08D),
    },
    {
      'icon': Icons.shopping_bag,
      'label': 'Shops',
      'c1': Color(0xFF8E2DE2),
      'c2': Color(0xFF4A00E0),
    },
    {
      'icon': Icons.spa,
      'label': 'Parlour',
      'c1': Color(0xFFf953c6),
      'c2': Color(0xFFb91d73),
    },
  ];

  // ── B2B Static Categories ──
  static const _b2bCategories = [
    {
      'icon': Icons.science, // Chemical-க்கு Science icon
      'label': 'Chemical',
      'c1': Color(0xFF373B44),
      'c2': Color(0xFF4286f4),
    },
    {
      'icon': Icons.electrical_services, // Electrical services icon
      'label': 'Electrical',
      'c1': Color(0xFFF7971E),
      'c2': Color(0xFFFFD200),
    },
    {
      'icon': Icons.foundation, // Steel/Iron works-க்கு foundation icon
      'label': 'Steel',
      'c1': Color(0xFF607D8B), // Steel Grey look
      'c2': Color(0xFF90A4AE),
    },
    {
      'icon': Icons.settings_suggest, // CNC Machining-க்கு settings icon
      'label': 'CNC',
      'c1': Color(0xFFDA4453),
      'c2': Color(0xFF89216B),
    },
    {
      'icon': Icons.memory, // Electronics/Chips-க்கு memory icon
      'label': 'Electronics',
      'c1': Color(0xFF8E2DE2),
      'c2': Color(0xFF4A00E0),
    },
    {
      'icon': Icons.architecture, // Builder/Architecture icon
      'label': 'Builder',
      'c1': Color(0xFFf46b45),
      'c2': Color(0xFFeea849),
    },
    {
      'icon': Icons.water_drop, // Hydraulic/Pumps-க்கு water icon
      'label': 'Hydraulic',
      'c1': Color(0xFF1FA2FF),
      'c2': Color(0xFF12D8FA),
    },
    {
      'icon': Icons.factory, // பொதுவான Industrial-க்கு
      'label': 'Industrial',
      'c1': Color(0xFF11998E),
      'c2': Color(0xFF38EF7D),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();
    final bool isB2C = title.contains('B2C');

    final liveItems = isB2C
        ? controller.b2cCategories
        : controller.b2bCategories;
    final staticCategories = isB2C ? _b2cCategories : _b2bCategories;

    if (controller.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final bool useLive = liveItems.isNotEmpty;
    final displayCount = useLive
        ? (liveItems.length > 7 ? 7 : liveItems.length)
        : (staticCategories.length > 7 ? 7 : staticCategories.length);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: isB2C
                        ? [const Color(0xFF667EEA), const Color(0xFFFC5C7D)]
                        : [const Color(0xFF11998E), const Color(0xFF38EF7D)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/search'),
                child: Text(
                  'See All',
                  style: TextStyle(
                    color: isB2C
                        ? const Color(0xFF667EEA)
                        : const Color(0xFF11998E),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayCount + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              if (index == displayCount) return _MoreTile(isB2C: isB2C);

              if (useLive) {
                final liveItem = liveItems[index];
                final matched = staticCategories.firstWhere(
                  (s) =>
                      (s['label'] as String).toLowerCase().contains(
                        liveItem.title.toLowerCase(),
                      ) ||
                      liveItem.title.toLowerCase().contains(
                        (s['label'] as String).toLowerCase(),
                      ),
                  orElse: () =>
                      staticCategories[index % staticCategories.length],
                );
                return _CategoryCard(
                  item: liveItem,
                  icon: matched['icon'] as IconData,
                  color1: matched['c1'] as Color,
                  color2: matched['c2'] as Color,
                );
              }

              final s = staticCategories[index];
              return _CategoryCard(
                item: CategoryItemModel(
                  title: s['label'] as String,
                  keywords: (s['label'] as String).toLowerCase(),
                  image: '',
                ),
                icon: s['icon'] as IconData,
                color1: s['c1'] as Color,
                color2: s['c2'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryItemModel item;
  final IconData icon;
  final Color color1;
  final Color color2;

  const _CategoryCard({
    required this.item,
    required this.icon,
    required this.color1,
    required this.color2,
  });

  // Updated Keys to match Title/Keywords
  static const Map<String, List<String>> _subcategories = {
    'college': [
      'Arts College',
      'Engineering College',
      'Medical College',
      'Polytechnic College',
      'Nursing College',
      'Law College',
      'Management College',
    ],
    'doctor': [
      'Cardiologist',
      'Dentist',
      'Dermatologist',
      'Pediatrician',
      'Orthopedic',
      'Gynecologist',
      'Neurologist',
      'ENT Specialist',
    ],
    'hospital': [
      'Ent Hospital',
      'Children Hospital',
      'Eye Hospital',
      'Ortho Hospital',
      'Maternity Hospital',
      'Cancer Hospital',
      'Heart Hospital',
    ],
    'hotel': [
      'Luxury Hotels',
      'Budget Hotels',
      'Resorts',
      'Homestays',
      'Lodges',
      'Service Apartments',
    ],
    'travel': [
      'Travel Agents',
      'Tour Packages',
      'Cab Services',
      'Bus Operators',
      'Visa Services',
    ],
    'shop': [
      'Supermarket',
      'Clothing Store',
      'Electronics Shop',
      'Jewellery Shop',
      'Furniture Shop',
    ],
    'parlour': [
      'Beauty Parlour',
      'Hair Salon',
      'Spa & Massage',
      'Bridal Makeup',
    ],
  };

  void _onTap(BuildContext context) {
    // Check match in both title and keywords
    final searchTarget = "${item.title} ${item.keywords}".toLowerCase();

    String matchKey = '';
    for (var key in _subcategories.keys) {
      if (searchTarget.contains(key)) {
        matchKey = key;
        break;
      }
    }

    if (matchKey.isEmpty) {
      context.push('/search?service=${Uri.encodeComponent(item.title)}');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (ctx, scroll) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${item.title} Subcategories',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  controller: scroll,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        2, // 2 column layout looks better for text buttons
                    childAspectRatio: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: _subcategories[matchKey]!.length,
                  itemBuilder: (context, i) {
                    final sub = _subcategories[matchKey]![i];
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        context.push(
                          '/search?service=${Uri.encodeComponent(sub)}',
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: color1.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: color1.withOpacity(0.3)),
                        ),
                        child: Text(
                          sub,
                          style: TextStyle(
                            color: color1,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = item.image.startsWith('http');
    return InkWell(
      onTap: () => _onTap(context),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            child: hasImage
                ? ClipRRect(
                    // borderRadius: BorderRadius.circular(8), // optional
                    child: Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                    ),
                  )
                : Icon(icon, color: Colors.blue, size: 40),
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final bool isB2C;
  const _MoreTile({required this.isB2C});

  @override
  Widget build(BuildContext context) {
    final Color c1 = isB2C ? const Color(0xFF667EEA) : const Color(0xFF11998E);
    final Color c2 = isB2C ? const Color(0xFFFC5C7D) : const Color(0xFF38EF7D);

    return InkWell(
      onTap: () => context.push('/search'),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              // shape: BoxShape.circle,
              color: Colors.transparent,
              // border: Border.all(color: Colors.blue, width: 1.8),
            ),
            child: const Icon(
              Icons.grid_view_rounded,
              color: Colors.blue,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'More',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
