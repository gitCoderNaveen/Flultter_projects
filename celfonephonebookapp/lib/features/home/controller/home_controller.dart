import 'package:flutter/material.dart';
import '../service/home_service.dart';
import '../model/carousel_item.dart';
import '../model/popular_firm_model.dart';
import '../model/category_item_model.dart';

class HomeController extends ChangeNotifier {
  final HomeService _service;

  HomeController(this._service);

  /// DATA
  List<CarouselItem> carouselImages = [];
  List<PopularFirmModel> popularFirms = [];
  List<CategoryItemModel> b2cCategories = [];
  List<CategoryItemModel> b2bCategories = [];

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

      /// Fetch B2C & B2B Categories
      final allCategories = await _service.fetchCategories();
      b2cCategories = allCategories.where((c) => c.isB2C).toList();
      b2bCategories = allCategories.where((c) => c.isB2B).toList();

      debugPrint('ADS COUNT: \${carouselImages.length}');
      debugPrint('B2C COUNT: \${b2cCategories.length}');
      debugPrint('B2B COUNT: \${b2bCategories.length}');
    } catch (e, stack) {
      error = e.toString();
      debugPrint('HOME LOAD ERROR: \$e');
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
