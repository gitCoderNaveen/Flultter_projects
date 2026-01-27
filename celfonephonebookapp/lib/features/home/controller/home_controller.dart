import 'package:flutter/material.dart';
import '../service/home_service.dart';
import '../model/carousel_item.dart';

class HomeController extends ChangeNotifier {
  final HomeService _service;

  List<CarouselItem> carouselImages = [];
  List<String> popularFirms = [];
  bool loading = true;

  HomeController(this._service);

  Future<void> loadData() async {
    loading = true;
    notifyListeners();

    carouselImages = await _service.fetchAds();
    popularFirms = await _service.fetchPopularFirms();

    debugPrint('ADS COUNT: ${carouselImages.length}');
    if (carouselImages.isNotEmpty) {
      debugPrint('FIRST IMAGE: ${carouselImages.first.imageUrl}');
    }

    loading = false;
    notifyListeners();
  }
}
