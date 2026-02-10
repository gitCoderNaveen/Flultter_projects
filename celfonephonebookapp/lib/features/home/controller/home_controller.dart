import 'package:flutter/material.dart';
import '../service/home_service.dart';
import '../model/carousel_item.dart';
import '../model/popular_firm_model.dart';

class HomeController extends ChangeNotifier {
  final HomeService _service;

  HomeController(this._service);

  /// DATA
  List<CarouselItem> carouselImages = [];
  List<PopularFirmModel> popularFirms = [];

  /// UI STATE
  bool loading = false;
  String? error;

  /// LOAD ALL HOME DATA
  Future<void> loadData() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      /// Fetch Ads
      carouselImages = await _service.fetchAds();

      /// Fetch Popular Firms

      debugPrint('ADS COUNT: ${carouselImages.length}');
      debugPrint('FIRMS COUNT: ${popularFirms.length}');

      if (popularFirms.isNotEmpty) {
        debugPrint('FIRST FIRM: ${popularFirms.first.title}');
      }
    } catch (e, stack) {
      error = e.toString();
      debugPrint('HOME LOAD ERROR: $e');
      debugPrintStack(stackTrace: stack);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// OPTIONAL: MANUAL REFRESH
  Future<void> refresh() async {
    await loadData();
  }
}
