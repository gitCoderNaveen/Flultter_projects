import 'package:flutter/material.dart';

class PartnersPage extends StatefulWidget {
  PartnersPage({super.key});

  @override
  State<PartnersPage> createState() => _PartnersPageState();
}

class _PartnersPageState extends State<PartnersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Partners')),
      body: const Center(child: Text('Partner details will be shown here')),
    );
  }
}
