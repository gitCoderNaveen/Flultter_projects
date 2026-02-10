import 'package:celfonephonebookapp/features/home/model/popular_firm_model.dart';
import 'package:celfonephonebookapp/features/home/service/popular_firm_service.dart';
import 'package:flutter/material.dart';

class PopularFirmController extends ChangeNotifier {
  bool loading = false;
  List<PopularFirmModel> firms = [];

  Future<void> loadFirms() async {
    loading = true;
    notifyListeners();

    firms = await PopularFirmService.getPopularFirms();

    loading = false;
    notifyListeners();
  }
}
