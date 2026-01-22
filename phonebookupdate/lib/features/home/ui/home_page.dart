import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/home_controller.dart';
import '../service/home_service.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            _Header(),
            _SearchBar(),
            _Greeting(),
            _Carousel(c),
            _PopularFirms(c),
          ],
        ),
      ),
    );
  }
}

class _Carousel extends StatelessWidget {
  final HomeController c;
  const _Carousel(this.c);

  @override
  Widget build(BuildContext context) {
    if (c.loading) return const CircularProgressIndicator();

    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: c.carouselImages.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            '/ad',
            arguments: c.carouselImages[i],
          ),
          child: Image.network(c.carouselImages[i], fit: BoxFit.cover),
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
          Image.asset('images/ic_launcher.png', width: 36, height: 36),
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

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to search page
        },
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A96BD),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: const [
              Icon(Icons.search, color: Colors.black),
              SizedBox(width: 12),
              VerticalDivider(color: Colors.black54),
              SizedBox(width: 12),
              Text(
                'Search “Person”',
                style: TextStyle(color: Colors.black, fontSize: 16),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Hi User!',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Grow Together',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _PopularFirms extends StatelessWidget {
  final HomeController controller;
  const _PopularFirms(this.controller);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Firms',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: controller.popularFirms.length,
            itemBuilder: (_, index) {
              final firm = controller.popularFirms[index];

              return GestureDetector(
                onTap: () {
                  // TODO: Navigate to category
                },
                child: Column(
                  children: [
                    const Icon(Icons.business, size: 36),
                    const SizedBox(height: 6),
                    Text(
                      firm,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
