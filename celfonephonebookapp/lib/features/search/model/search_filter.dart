enum SearchFilter {
  business,
  products,
  city;

  String get label {
    switch (this) {
      case SearchFilter.business:
        return "Business";
      case SearchFilter.products:
        return "Product";
      case SearchFilter.city:
        return "city";
    }
  }
}
