import 'package:flutter/material.dart';
import '../model/categorywise_pro_model.dart';
import '../service/categorywise_pro_services.dart';

class CategorywiseProController extends ChangeNotifier {
  final CategorywiseProServices _service = CategorywiseProServices();

  bool isSearching = false;
  bool hasSearched = false;

  List<CategorywiseProModel> searchResults = [];

  Set<int> selectedIndices = {};
  Set<String> sentBusinessIds = {};

  final messageController = TextEditingController(
    text:
        "I Saw Your Listing in SIGNPOST PHONE BOOK. I am Interested in your Products. Please Send Details/Call Me.",
  );

  final categoryController = TextEditingController();
  final cityController = TextEditingController();

  Future<List<String>> getSuggestions(String column, String query) async {
    return await _service.getSuggestions(column, query);
  }

  Future<void> search() async {
    isSearching = true;
    notifyListeners();

    try {
      final data = await _service.searchBusinesses(
        categoryController.text,
        cityController.text,
      );

      searchResults = data.map((e) => CategorywiseProModel.fromMap(e)).toList();

      selectedIndices.clear();
      hasSearched = true;
    } catch (e) {
      debugPrint(e.toString());
    }

    isSearching = false;
    notifyListeners();
  }

  Future<List<String>> getKeywordSuggestions(String query) async {
    if (query.isEmpty) return [];

    final result = await _service.getSuggestions("keywords", query);

    /// remove duplicates
    final unique = result.toSet().toList();

    /// optional: sort alphabetically
    unique.sort();

    return unique;
  }

  Future<bool> sendSMS() async {
    final numbers = selectedIndices
        .map((i) => searchResults[i].mobileNumber)
        .toList();

    final success = await _service.sendSMS(numbers, messageController.text);

    if (success) {
      for (var i in selectedIndices) {
        sentBusinessIds.add(searchResults[i].id);
      }

      selectedIndices.clear();

      searchResults.sort((a, b) {
        bool aSent = sentBusinessIds.contains(a.id);
        bool bSent = sentBusinessIds.contains(b.id);

        if (aSent && !bSent) return 1;
        if (!aSent && bSent) return -1;
        return 0;
      });

      notifyListeners();
    }

    return success;
  }

  void toggleSelection(int index) {
    if (selectedIndices.contains(index))
      selectedIndices.remove(index);
    else
      selectedIndices.add(index);

    notifyListeners();
  }

  void selectAll() {
    if (selectedIndices.length == searchResults.length)
      selectedIndices.clear();
    else
      selectedIndices = List.generate(searchResults.length, (i) => i).toSet();

    notifyListeners();
  }

  void clearAll() {
    hasSearched = false;
    searchResults.clear();
    selectedIndices.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    messageController.dispose();
    categoryController.dispose();
    cityController.dispose();

    super.dispose();
  }
}
