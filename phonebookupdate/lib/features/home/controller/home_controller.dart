import 'package:flutter/material.dart';
import '../service/home_service.dart';

class HomeController extends ChangeNotifier {
  final HomeService _service;

  List<String> carouselImages = [];
  List<String> popularFirms = [];
  bool loading = true;

  HomeController(this._service);

  Future<void> loadData() async {
    loading = true;
    notifyListeners();

    carouselImages = await _service.fetchAds();
    popularFirms = await _service.fetchPopularFirms();

    loading = false;
    notifyListeners();
  }
}
