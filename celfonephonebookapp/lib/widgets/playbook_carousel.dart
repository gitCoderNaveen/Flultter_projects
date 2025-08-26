import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';


class PlayBookWidget extends StatelessWidget {
  final List<String> images;
  final List<String> links;

  const PlayBookWidget({super.key, required this.images, required this.links,});

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: images.length,
      controller: PageController(viewportFraction: 0.85),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _openLink(links[index]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                images[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}

