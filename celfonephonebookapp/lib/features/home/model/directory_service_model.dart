class DirectoryService {
  final String title;
  final String image;
  final String searchValue;
  final String? redirectUrl;

  DirectoryService({
    required this.title,
    required this.image,
    required this.searchValue,
    this.redirectUrl,
  });
}
