import 'package:celfonephonebookapp/core/services/profile_service.dart';
import 'package:celfonephonebookapp/features/home/controller/popular_firm_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controller/home_controller.dart';
import '../service/home_service.dart';
import 'dart:async';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(HomeService())..loadData(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<HomeController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: CustomScrollView(
        slivers: [
          _AnimatedHeader(),
          SliverToBoxAdapter(child: _Greeting()),
          SliverToBoxAdapter(child: _Carousel(c)),
          SliverToBoxAdapter(child: _IndexFinder()),
          SliverToBoxAdapter(child: _PopularFirms()),
        ],
      ),
    );
  }
}

class _AnimatedHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 160,
      collapsedHeight: 80,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final top = constraints.biggest.height;
          final bool collapsed = top <= 100;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.only(top: 40),
            decoration: BoxDecoration(
              color: collapsed ? Colors.white : const Color(0xFF1F8EB6),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                _HeaderRow(collapsed: collapsed),
                const SizedBox(height: 12),
                const _StickySearchBar(),
              ],
            ),
          );
        },
      ),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('images/ic_launcher.png', width: 36, height: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              child: const Text('Celfon Book', textAlign: TextAlign.center),
            ),
          ),
          Icon(Icons.notifications_none, color: color),
        ],
      ),
    );
  }
}

class _StickySearchBar extends StatelessWidget {
  const _StickySearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          context.push('/search');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: const [
              Icon(Icons.search, color: Colors.black),
              SizedBox(width: 12),
              Text(
                'Search people or businesses',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullScreenImage({
    super.key,
    required this.imageUrl,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class _Carousel extends StatefulWidget {
  final HomeController c;
  const _Carousel(this.c);

  @override
  State<_Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<_Carousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || widget.c.carouselImages.isEmpty) return;

      _currentPage = (_currentPage + 1) % widget.c.carouselImages.length;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.c;

    if (c.loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 120,
        child: PageView.builder(
          controller: _pageController,
          itemCount: c.carouselImages.length,
          onPageChanged: (i) => _currentPage = i,
          itemBuilder: (_, i) {
            final item = c.carouselImages[i];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (_, __, ___) => FullScreenImage(
                      imageUrl: item.redirectUrl,
                      heroTag: 'carousel_$i',
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'carousel_$i',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (_, __, ___) {
                      return const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1F8EB6),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10), // adjust radius as needed
            child: Image.asset(
              'images/ic_launcher.png',
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Phone Book+',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: notification screen
            },
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final List<String> _searchHints = ['Person', 'Business', 'Spinning'];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return false;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _searchHints.length;
      });
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          // Navigate to search page
        },
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A96BD),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.black),
              const SizedBox(width: 12),
              const VerticalDivider(color: Colors.black54),
              const SizedBox(width: 12),

              /// Animated text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  'Search "${_searchHints[_currentIndex]}"',
                  key: ValueKey(_searchHints[_currentIndex]),
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: ProfileService.getProfile(),
      builder: (context, snapshot) {
        String name = 'Guest';

        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!['full_name'] != null &&
            snapshot.data!['full_name'].toString().isNotEmpty) {
          name = snapshot.data!['full_name'];
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi $name!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Grow Together',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IndexFinder extends StatelessWidget {
  final List<String> alphabets = List.generate(
    26,
    (i) => String.fromCharCode(65 + i),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Index Finder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: alphabets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final letter = alphabets[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    context.push('/search?letter=$letter');
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.red, // 🔴 outline color
                        width: 2, // outline thickness
                      ),
                    ),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularFirms extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PopularFirmController()..loadFirms(),
      child: Consumer<PopularFirmController>(
        builder: (context, c, _) {
          if (c.loading) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (c.firms.isEmpty) {
            return const SizedBox();
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Popular Firms',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: c.firms.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (_, index) {
                    final item = c.firms[index];
                    return Column(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.network(
                            item.imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image_not_supported),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
