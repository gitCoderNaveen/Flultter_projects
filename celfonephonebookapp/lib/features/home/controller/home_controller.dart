import 'package:celfonephonebookapp/features/home/model/popular_firm_model.dart';
import 'package:flutter/material.dart';
import '../service/home_service.dart';
import '../model/carousel_item.dart';

class HomeController extends ChangeNotifier {
  final HomeService _service;

  List<CarouselItem> carouselImages = [];
  List<PopularFirmModel> popularFirms = [];

  bool loading = true;

  HomeController(this._service);

  Future<void> loadData() async {
    try {
      loading = true;
      notifyListeners();

      /// Fetch Ads
      carouselImages = await _service.fetchAds();

      /// Fetch Popular Firms
      popularFirms = await _service.fetchPopularFirms();

      debugPrint('ADS COUNT: ${carouselImages.length}');
      debugPrint('FIRMS COUNT: ${popularFirms.length}');

      if (popularFirms.isNotEmpty) {
        debugPrint('FIRST FIRM: ${popularFirms.first.name}');
      }
    } catch (e) {
      debugPrint('Home Load Error: $e');
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
