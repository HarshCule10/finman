/// Model representing an expense category with budget tracking and favorite status
class CategoryModel {
  final String id;
  final String name;
  final String iconName; // Material icon name as string
  final double? budgetLimit; // Optional monthly budget
  final bool isFavorite;
  final int colorValue; // Color for category representation
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    this.budgetLimit,
    this.isFavorite = false,
    required this.colorValue,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Creates a copy of this CategoryModel with the given fields replaced
  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconName,
    double? budgetLimit,
    bool? isFavorite,
    int? colorValue,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      isFavorite: isFavorite ?? this.isFavorite,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt,
    );
  }

  /// Converts this CategoryModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'budgetLimit': budgetLimit,
      'isFavorite': isFavorite,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a CategoryModel from a JSON map
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['iconName'] as String,
      budgetLimit: json['budgetLimit'] as double?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      colorValue: json['colorValue'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
