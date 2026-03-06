enum SearchFilter {
  business,
  products;

  String get label {
    switch (this) {
      case SearchFilter.business:
        return "Business";
      case SearchFilter.products:
        return "Product";
    }
  }
}
