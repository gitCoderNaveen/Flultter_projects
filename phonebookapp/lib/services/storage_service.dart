import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final _client = Supabase.instance.client;
  final _bucket = 'public'; // create this bucket in Supabase Storage

  Future<String> uploadImage(File file, String pathPrefix) async {
    final fileName = '${pathPrefix}/${Uuid().v4()}.jpg';
    await _client.storage.from(_bucket).upload(fileName, file);
    final url = _client.storage.from(_bucket).getPublicUrl(fileName);
    return url;
  }
}
