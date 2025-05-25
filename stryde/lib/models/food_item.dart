class FoodItem {
  final String id;
  final String name;
  final String brand;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  final double sugar;
  final String servingDescription;
  final double servingSize;
  final String servingUnit;

  FoodItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sugar,
    required this.servingDescription,
    required this.servingSize,
    required this.servingUnit,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['food_id']?.toString() ?? '',
      name: json['food_name'] ?? '',
      brand: json['brand_name'] ?? '',
      calories: double.tryParse(json['food_description']?.toString().split('Calories: ')[1]?.split(' ')[0] ?? '0') ?? 0.0,
      protein: _extractNutrient(json['food_description'], 'Protein'),
      carbs: _extractNutrient(json['food_description'], 'Carbs'),
      fat: _extractNutrient(json['food_description'], 'Fat'),
      fiber: _extractNutrient(json['food_description'], 'Fiber'),
      sugar: _extractNutrient(json['food_description'], 'Sugar'),
      servingDescription: json['food_description'] ?? '',
      servingSize: 1.0,
      servingUnit: 'serving',
    );
  }

  static double _extractNutrient(String? description, String nutrient) {
    if (description == null) return 0.0;
    final regex = RegExp('$nutrient: ([0-9.]+)g');
    final match = regex.firstMatch(description);
    return double.tryParse(match?.group(1) ?? '0') ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'servingDescription': servingDescription,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
    };
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? brand,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? fiber,
    double? sugar,
    String? servingDescription,
    double? servingSize,
    String? servingUnit,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      servingDescription: servingDescription ?? this.servingDescription,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
    );
  }
}