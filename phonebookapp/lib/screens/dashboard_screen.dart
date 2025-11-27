import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../services/storage_service.dart';

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _auth = AuthService();
  final _data = DataService();
  final _storage = StorageService();

  final _rootKeywordCtrl = TextEditingController();
  final _keywordCtrl = TextEditingController();
  final _rootProductCtrl = TextEditingController();
  final _productNameCtrl = TextEditingController();
  final _productDescCtrl = TextEditingController();

  String? _selectedRootKeywordId;
  String? _selectedRootProductId;

  List<Map<String, dynamic>> _rootKeywords = [];
  List<Map<String, dynamic>> _keywords = [];
  List<Map<String, dynamic>> _rootProducts = [];
  List<Map<String, dynamic>> _carousel = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _rootKeywords = await _data.fetchRootKeywords();
    _rootProducts = await _data.fetchRootProducts();
    _carousel = await _data.fetchCarousel();
    setState(() {});
  }

  Future<void> _uploadCarousel() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final url =
      await _storage.uploadImage(File(picked.path), 'carousel_images');
      await _data.addCarouselImage(url);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Root Keywords', style: Theme.of(context).textTheme.headline6),
          TextField(controller: _rootKeywordCtrl, decoration: InputDecoration(labelText: 'Keyword')),
          ElevatedButton(onPressed: () async {
            await _data.createRootKeyword(_rootKeywordCtrl.text);
            _rootKeywordCtrl.clear();
            _loadData();
          }, child: Text('Add Root Keyword')),
          Divider(),
          Text('Root Products', style: Theme.of(context).textTheme.headline6),
          TextField(controller: _rootProductCtrl, decoration: InputDecoration(labelText: 'Category')),
          ElevatedButton(onPressed: () async {
            await _data.createRootProduct(_rootProductCtrl.text);
            _rootProductCtrl.clear();
            _loadData();
          }, child: Text('Add Root Product')),
          Divider(),
          Text('Carousel', style: Theme.of(context).textTheme.headline6),
          ElevatedButton(onPressed: _uploadCarousel, child: Text('Upload Image')),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _carousel
                  .map((e) => Padding(
                padding: const EdgeInsets.all(8),
                child: Image.network(e['image_url'], width: 100, height: 100),
              ))
                  .toList(),
            ),
          ),
        ]),
      ),
    );
  }
}
