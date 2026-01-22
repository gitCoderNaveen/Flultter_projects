import 'package:flutter/material.dart';

class PromotionsPage extends StatefulWidget {
  PromotionsPage({super.key});

  @override
  State<PromotionsPage> createState() => _PromotionsPageState();
}

class _PromotionsPageState extends State<PromotionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promotions')),
      body: const Center(child: Text('Promotions from backend')),
    );
  }
}
