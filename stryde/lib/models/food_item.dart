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
    // Print the JSON structure for debugging
    print('FoodItem.fromJson: ${json.toString()}');
    
    // Get the servings information
    final servings = json['servings']?['serving'];
    Map<String, dynamic>? defaultServing;
    
    if (servings != null) {
      if (servings is List) {
        // Find the default serving (usually the first one)
        defaultServing = Map<String, dynamic>.from(servings.first);
      } else if (servings is Map<String, dynamic>) {
        defaultServing = servings;
      } else if (servings is Map) {
        defaultServing = Map<String, dynamic>.from(servings);
      }
    }
    
    // Extract nutritional information from the serving or description
    double calories = double.tryParse(json['calories']?.toString() ?? '0') ?? 0.0;
    double protein = 0.0;
    double carbs = 0.0;
    double fat = 0.0;
    double fiber = 0.0;
    double sugar = 0.0;
    String servingDescription = '';
    double servingSize = 1.0;
    String servingUnit = 'serving';
    
    if (defaultServing != null) {
      // Only update calories if not already set and available in serving
      if (calories == 0.0) {
        calories = double.tryParse(defaultServing['calories']?.toString() ?? '0') ?? 0.0;
      }
      protein = double.tryParse(defaultServing['protein']?.toString() ?? '0') ?? 0.0;
      carbs = double.tryParse(defaultServing['carbohydrate']?.toString() ?? '0') ?? 0.0;
      fat = double.tryParse(defaultServing['fat']?.toString() ?? '0') ?? 0.0;
      fiber = double.tryParse(defaultServing['fiber']?.toString() ?? '0') ?? 0.0;
      sugar = double.tryParse(defaultServing['sugar']?.toString() ?? '0') ?? 0.0;
      servingDescription = defaultServing['serving_description'] ?? '';
      servingSize = double.tryParse(defaultServing['metric_serving_amount']?.toString() ?? '1') ?? 1.0;
      servingUnit = defaultServing['metric_serving_unit'] ?? 'serving';
    } else if (json.containsKey('food_description')) {
      // Fallback to extracting from description
      calories = _extractNutrient(json['food_description'], 'Calories');
      protein = _extractNutrient(json['food_description'], 'Protein');
      carbs = _extractNutrient(json['food_description'], 'Carbs');
      fat = _extractNutrient(json['food_description'], 'Fat');
      fiber = _extractNutrient(json['food_description'], 'Fiber');
      sugar = _extractNutrient(json['food_description'], 'Sugar');
      servingDescription = json['food_description'] ?? '';
    }
    
    return FoodItem(
      id: json['food_id']?.toString() ?? '',
      name: json['food_name'] ?? json['name'] ?? '',
      brand: json['brand_name'] ?? json['brand'] ?? '',
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      servingDescription: servingDescription,
      servingSize: servingSize,
      servingUnit: servingUnit,
    );
  }

  static double _extractNutrient(String? description, String nutrient) {
    if (description == null) return 0.0;
    
    // Handle calories differently as they don't have a 'g' suffix
    if (nutrient == 'Calories') {
      // Try different calorie formats
      final patterns = [
        RegExp('$nutrient: ([0-9.]+)'),
        RegExp('([0-9.]+) $nutrient'),
        RegExp('$nutrient ([0-9.]+)'),
      ];
      
      for (final regex in patterns) {
        final match = regex.firstMatch(description);
        if (match != null) {
          return double.tryParse(match.group(1) ?? '0') ?? 0.0;
        }
      }
    } else {
      // For other nutrients, try with and without 'g' suffix
      final patterns = [
        RegExp('$nutrient: ([0-9.]+)g'),
        RegExp('$nutrient: ([0-9.]+) g'),
        RegExp('$nutrient ([0-9.]+)g'),
        RegExp('([0-9.]+)g $nutrient'),
        RegExp('$nutrient: ([0-9.]+)'), // Try without 'g' suffix as fallback
      ];
      
      for (final regex in patterns) {
        final match = regex.firstMatch(description);
        if (match != null) {
          return double.tryParse(match.group(1) ?? '0') ?? 0.0;
        }
      }
    }
    
    return 0.0; // Return 0 if no match found
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