import 'food_item.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

class Meal {
  final MealType type;
  final List<MealFoodItem> foodItems;
  final DateTime date;

  Meal({
    required this.type,
    required this.foodItems,
    required this.date,
  });

  String get displayName {
    switch (type) {
      case MealType.breakfast:
        return 'Pequeno-almoço';
      case MealType.lunch:
        return 'Almoço';
      case MealType.dinner:
        return 'Jantar';
      case MealType.snack:
        return 'Lanche';
    }
  }

  double get totalCalories {
    return foodItems.fold(0.0, (sum, item) => sum + item.totalCalories);
  }

  double get totalProtein {
    return foodItems.fold(0.0, (sum, item) => sum + item.totalProtein);
  }

  double get totalCarbs {
    return foodItems.fold(0.0, (sum, item) => sum + item.totalCarbs);
  }

  double get totalFat {
    return foodItems.fold(0.0, (sum, item) => sum + item.totalFat);
  }

  Meal copyWith({
    MealType? type,
    List<MealFoodItem>? foodItems,
    DateTime? date,
  }) {
    return Meal(
      type: type ?? this.type,
      foodItems: foodItems ?? this.foodItems,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'foodItems': foodItems.map((item) => item.toJson()).toList(),
      'date': date.toIso8601String(),
    };
  }

  factory Meal.fromJson(Map<String, dynamic> json) {
    print('Meal.fromJson: ${json.toString()}');
    
    final meal = Meal(
      type: MealType.values[json['type']],
      foodItems: (json['foodItems'] as List)
          .map((item) => MealFoodItem.fromJson(item))
          .toList(),
      date: DateTime.parse(json['date']),
    );
    
    print('Meal created:');
    print('  Type: ${meal.displayName}');
    print('  Food Items Count: ${meal.foodItems.length}');
    print('  Total Calories: ${meal.totalCalories}');
    
    return meal;
  }
}

class MealFoodItem {
  final FoodItem foodItem;
  final double quantity;
  final String unit;

  MealFoodItem({
    required this.foodItem,
    required this.quantity,
    required this.unit,
  }) {
    // Debug print to verify food item data
    print('MealFoodItem created:');
    print('  Name: ${foodItem.name}');
    print('  Calories: ${foodItem.calories}');
    print('  Quantity: $quantity');
    print('  Unit: $unit');
    print('  Total Calories: ${foodItem.calories * quantity}');
  }

  double get totalCalories => foodItem.calories * quantity;
  double get totalProtein => foodItem.protein * quantity;
  double get totalCarbs => foodItem.carbs * quantity;
  double get totalFat => foodItem.fat * quantity;
  double get totalFiber => foodItem.fiber * quantity;
  double get totalSugar => foodItem.sugar * quantity;

  String get displayPortion => '${quantity.toStringAsFixed(0)}$unit';

  MealFoodItem copyWith({
    FoodItem? foodItem,
    double? quantity,
    String? unit,
  }) {
    return MealFoodItem(
      foodItem: foodItem ?? this.foodItem,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodItem': foodItem.toJson(),
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory MealFoodItem.fromJson(Map<String, dynamic> json) {
    print('MealFoodItem.fromJson: ${json.toString()}');
    
    final foodItemJson = json['foodItem'];
    print('Food Item JSON: $foodItemJson');
    
    final foodItem = FoodItem.fromJson(foodItemJson);
    print('Food Item created:');
    print('  Name: ${foodItem.name}');
    print('  Calories: ${foodItem.calories}');
    
    return MealFoodItem(
      foodItem: foodItem,
      quantity: json['quantity']?.toDouble() ?? 1.0,
      unit: json['unit'] ?? 'g',
    );
  }
}