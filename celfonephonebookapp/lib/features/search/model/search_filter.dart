enum SearchFilter { business, products, city }

extension SearchFilterX on SearchFilter {
  String get label {
    switch (this) {
      case SearchFilter.business:
        return 'Business';
      case SearchFilter.products:
        return 'Products';
      case SearchFilter.city:
        return 'City';
    }
  }
}
