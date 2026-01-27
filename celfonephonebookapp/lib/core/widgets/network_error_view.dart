import 'package:flutter/material.dart';

class NetworkErrorView extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/ic_launcher.png', width: 100),
          const SizedBox(height: 20),
          const Text(
            'Check your network connection',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
