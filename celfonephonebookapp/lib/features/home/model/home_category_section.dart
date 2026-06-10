import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../home/controller/home_controller.dart';
import '../../home/model/category_item_model.dart';

class HomeCategoriesSection extends StatelessWidget {
  final String title;
  const HomeCategoriesSection({super.key, required this.title});

  // ── B2C Static Categories (Emoji Edition) ──
  static const _b2cCategories = [
    {'icon': '🏥', 'label': 'Hospital'},
    {'icon': '🏩', 'label': 'Hotel'},
    {'icon': '🎓', 'label': 'Colleges'},
    {'icon': '✈️', 'label': 'Travel'},
    {'icon': '🩺', 'label': 'Doctors'},
    {'icon': '🛍️', 'label': 'Shops'},
    {'icon': '💅', 'label': 'Parlour'},
  ];

  // ── B2B Static Categories (Emoji Edition) ──
  static const _b2bCategories = [
    {'icon': '🧪', 'label': 'Chemical'},
    {'icon': '⚡', 'label': 'Electrical'},
    {'icon': '🏗️', 'label': 'Steel'},
    {'icon': '⚙️', 'label': 'CNC'},
    {'icon': '📟', 'label': 'Electronics'},
    {'icon': '👷', 'label': 'Builder'},
    {'icon': '💧', 'label': 'Hydraulic'},
    {'icon': '🏭', 'label': 'Industrial'},
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
                  color: Color.fromARGB(255, 2, 2, 248),
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
              childAspectRatio: 0.85, // Adjusted to fit without background
              crossAxisSpacing: 10,
              mainAxisSpacing: 16,
            ),
            itemBuilder: (context, index) {
              if (index == displayCount) return const _MoreTile();

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
                  emoji: matched['icon'] as String,
                );
              }

              final s = staticCategories[index];
              return _CategoryCard(
                item: CategoryItemModel(
                  title: s['label'] as String,
                  keywords: (s['label'] as String).toLowerCase(),
                  image: '',
                ),
                emoji: s['icon'] as String,
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
  final String emoji;

  const _CategoryCard({required this.item, required this.emoji});

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
                    crossAxisCount: 2,
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
                          color: const Color(0xFF667EEA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF667EEA).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          sub,
                          style: const TextStyle(
                            // You can keep the style const if you want
                            color: Color(0xFF667EEA),
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
      child: Column(
        children: [
          Container(
            width: 50, // Slightly smaller container since there's no background
            height: 50,
            alignment: Alignment.center,
            child: hasImage
                ? ClipOval(child: Image.network(item.image, fit: BoxFit.cover))
                : Text(
                    emoji,
                    style: const TextStyle(
                      fontSize: 36, // Arranged correct size for the emoji
                    ),
                  ),
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
  const _MoreTile();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/search'),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            child: const Text(
              '➕', // Using an emoji for the "More" tile
              style: TextStyle(fontSize: 32), // arranged correct size
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
