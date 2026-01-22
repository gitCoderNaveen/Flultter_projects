class L {
  static const Map<String, Map<String, String>> values = {
    'en': {
      'hi_user': 'Hi User!',
      'grow': 'Grow Together',
      'search': 'Search Person',
    },
    'TA': {
      'hi_user': 'வணக்கம்!',
      'grow': 'உங்கள் வளர்ச்சியில் உதவுகிறோம்',
      'search': 'எளிதாக தேட',
    },
  };

  static String t(String key, String locale) {
    return values[locale]?[key] ?? key;
  }
}
