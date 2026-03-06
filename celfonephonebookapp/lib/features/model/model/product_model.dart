class ProductModel {
  final String id;
  final String profileId;
  final String name;
  final String image;
  final String description;
  final String price;

  ProductModel({
    required this.id,
    required this.profileId,
    required this.name,
    required this.image,
    required this.description,
    required this.price,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'].toString(),
      profileId: map['profile_id'].toString(),
      name: map['product_name'] ?? '',
      image: map['product_image'] ?? '',
      description: map['product_description'] ?? '',
      price: map['price'] ?? '',
    );
  }
}
