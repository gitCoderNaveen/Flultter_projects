import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdDetailsPage extends StatelessWidget {
  final String adId;

  const AdDetailsPage({super.key, required this.adId});

  Future<String> _fetchImage() async {
    final res = await Supabase.instance.client
        .from('ads')
        .select('image_url')
        .eq('id', adId)
        .single();

    return res['image_url'] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<String>(
        future: _fetchImage(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          return GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Image.network(snapshot.data!, fit: BoxFit.contain),
            ),
          );
        },
      ),
    );
  }
}
