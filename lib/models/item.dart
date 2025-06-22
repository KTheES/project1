class Item {
  final String id;
  final String storeImagePath;
  final String homeImagePath;
  final int price;
  final String? characterGifPath;

  Item({
    required this. id,
    required this.storeImagePath,
    required this.homeImagePath,
    required this.price,
    this.characterGifPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'storeImagePath': storeImagePath,
    'homeImagePath': homeImagePath,
    'price': price,
    if (characterGifPath != null) 'characterGifPath': characterGifPath,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
      id: json['id'],
      storeImagePath: json['storeImagePath'],
      homeImagePath: json['homeImagePath'],
      price: json['price'],
      characterGifPath: json['characterGifPath'],
      );
}