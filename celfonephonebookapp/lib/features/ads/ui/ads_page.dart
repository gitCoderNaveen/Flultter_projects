import 'package:flutter/material.dart';

class AdsPage extends StatefulWidget {
  AdsPage({super.key});

  @override
  State<AdsPage> createState() => _AdsPageState();
}

class _AdsPageState extends State<AdsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advertisements')),
      body: const Center(child: Text('Ads from Supabase')),
    );
  }
}
