class Category {
  final int? categoryID;
  final String name;
  final String? description;
  final String colorCode;
  final String? icon;
  
  // Getter để tương thích với code hiện tại
  int get id => categoryID ?? 0;
  
  // Getter cho số lượng deck (mock data for now)
  int get deckCount => 5;

  Category({
    this.categoryID,
    required this.name,
    this.description,
    this.colorCode = '#6c757d',
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'CategoryID': categoryID,
      'Name': name,
      'Description': description,
      'ColorCode': colorCode,
      'Icon': icon,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      categoryID: map['CategoryID'],
      name: map['Name'],
      description: map['Description'],
      colorCode: map['ColorCode'] ?? '#6c757d',
      icon: map['Icon'],
    );
  }

  // Factory constructor từ JSON (cho API calls)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryID: json['CategoryID'] ?? json['id'] ?? json['category_id'],
      name: json['Name'] ?? json['name'] ?? 'Unknown',
      description: json['Description'] ?? json['description'],
      colorCode: json['ColorCode'] ?? json['color_code'] ?? '#6c757d',
      icon: json['Icon'] ?? json['icon'],
    );
  }

  // Chuyển đổi thành JSON (cho API calls)
  Map<String, dynamic> toJson() {
    return {
      'id': categoryID,
      'name': name,
      'description': description,
      'color_code': colorCode,
      'icon': icon,
    };
  }

  Category copyWith({
    int? categoryID,
    String? name,
    String? description,
    String? colorCode,
    String? icon,
  }) {
    return Category(
      categoryID: categoryID ?? this.categoryID,
      name: name ?? this.name,
      description: description ?? this.description,
      colorCode: colorCode ?? this.colorCode,
      icon: icon ?? this.icon,
    );
  }
}
