import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal.dart';
import '../models/food_item.dart';

class MealService {
  static const String _mealsKey = 'user_meals';
  
  // Singleton pattern
  static final MealService _instance = MealService._internal();
  factory MealService() => _instance;
  MealService._internal();

  /// Get all meals for a specific date
  Future<List<Meal>> getMealsForDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mealsJson = prefs.getString(_mealsKey);
      
      if (mealsJson == null) {
        return _getDefaultMeals(date);
      }

      final List<dynamic> mealsList = json.decode(mealsJson);
      final allMeals = mealsList.map((meal) => Meal.fromJson(meal)).toList();
      
      // Filter meals for the specific date
      final dateKey = _getDateKey(date);
      final mealsForDate = allMeals.where((meal) => 
        _getDateKey(meal.date) == dateKey
      ).toList();
      
      if (mealsForDate.isEmpty) {
        return _getDefaultMeals(date);
      }
      
      return mealsForDate;
    } catch (e) {
      print('Error getting meals: $e');
      return _getDefaultMeals(date);
    }
  }

  /// Save meals for a specific date
  Future<void> saveMeals(List<Meal> meals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing meals
      final existingMealsJson = prefs.getString(_mealsKey);
      List<Meal> allMeals = [];
      
      if (existingMealsJson != null) {
        final List<dynamic> mealsList = json.decode(existingMealsJson);
        allMeals = mealsList.map((meal) => Meal.fromJson(meal)).toList();
      }
      
      // Remove existing meals for the same date
      if (meals.isNotEmpty) {
        final dateKey = _getDateKey(meals.first.date);
        allMeals.removeWhere((meal) => _getDateKey(meal.date) == dateKey);
      }
      
      // Add new meals
      allMeals.addAll(meals);
      
      // Save to preferences
      final mealsJson = json.encode(allMeals.map((meal) => meal.toJson()).toList());
      await prefs.setString(_mealsKey, mealsJson);
    } catch (e) {
      print('Error saving meals: $e');
      throw Exception('Failed to save meals');
    }
  }

  /// Add a food item to a specific meal
  Future<void> addFoodToMeal(MealType mealType, FoodItem foodItem, double quantity, String unit, DateTime date) async {
    try {
      print('Adding food to meal:');
      print('  Food Name: ${foodItem.name}');
      print('  Food Calories: ${foodItem.calories}');
      print('  Quantity: $quantity');
      print('  Unit: $unit');
      
      final meals = await getMealsForDate(date);
      
      // Find the meal or create it if it doesn't exist
      Meal? targetMeal;
      int mealIndex = -1;
      
      for (int i = 0; i < meals.length; i++) {
        if (meals[i].type == mealType) {
          targetMeal = meals[i];
          mealIndex = i;
          break;
        }
      }
      
      if (targetMeal == null) {
        // Create new meal
        targetMeal = Meal(
          type: mealType,
          foodItems: [],
          date: date,
        );
        meals.add(targetMeal);
        mealIndex = meals.length - 1;
      }
      
      // Ensure food item has valid data
      final validFoodItem = FoodItem(
        id: foodItem.id,
        name: foodItem.name.isNotEmpty ? foodItem.name : 'Unknown Food',
        brand: foodItem.brand,
        calories: foodItem.calories,
        protein: foodItem.protein,
        carbs: foodItem.carbs,
        fat: foodItem.fat,
        fiber: foodItem.fiber,
        sugar: foodItem.sugar,
        servingDescription: foodItem.servingDescription,
        servingSize: foodItem.servingSize,
        servingUnit: foodItem.servingUnit,
      );
      
      print('Validated food item:');
      print('  Name: ${validFoodItem.name}');
      print('  Calories: ${validFoodItem.calories}');
      
      // Add food item to meal
      final mealFoodItem = MealFoodItem(
        foodItem: validFoodItem,
        quantity: quantity,
        unit: unit,
      );
      
      final updatedFoodItems = List<MealFoodItem>.from(targetMeal.foodItems)
        ..add(mealFoodItem);
      
      meals[mealIndex] = targetMeal.copyWith(foodItems: updatedFoodItems);
      
      await saveMeals(meals);
      print('Food added successfully to ${targetMeal.displayName}');
    } catch (e) {
      print('Error adding food to meal: $e');
      throw Exception('Failed to add food to meal');
    }
  }

  /// Remove a food item from a meal
  Future<void> removeFoodFromMeal(MealType mealType, int foodItemIndex, DateTime date) async {
    try {
      final meals = await getMealsForDate(date);
      
      // Find the meal
      for (int i = 0; i < meals.length; i++) {
        if (meals[i].type == mealType) {
          final updatedFoodItems = List<MealFoodItem>.from(meals[i].foodItems);
          if (foodItemIndex >= 0 && foodItemIndex < updatedFoodItems.length) {
            updatedFoodItems.removeAt(foodItemIndex);
            meals[i] = meals[i].copyWith(foodItems: updatedFoodItems);
            await saveMeals(meals);
          }
          break;
        }
      }
    } catch (e) {
      print('Error removing food from meal: $e');
      throw Exception('Failed to remove food from meal');
    }
  }

  /// Update food quantity in a meal
  Future<void> updateFoodQuantity(MealType mealType, int foodItemIndex, double newQuantity, DateTime date) async {
    try {
      final meals = await getMealsForDate(date);
      
      // Find the meal
      for (int i = 0; i < meals.length; i++) {
        if (meals[i].type == mealType) {
          final updatedFoodItems = List<MealFoodItem>.from(meals[i].foodItems);
          if (foodItemIndex >= 0 && foodItemIndex < updatedFoodItems.length) {
            updatedFoodItems[foodItemIndex] = updatedFoodItems[foodItemIndex].copyWith(
              quantity: newQuantity,
            );
            meals[i] = meals[i].copyWith(foodItems: updatedFoodItems);
            await saveMeals(meals);
          }
          break;
        }
      }
    } catch (e) {
      print('Error updating food quantity: $e');
      throw Exception('Failed to update food quantity');
    }
  }

  /// Get total nutrition for a date
  Future<Map<String, double>> getTotalNutritionForDate(DateTime date) async {
    try {
      final meals = await getMealsForDate(date);
      
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      
      for (final meal in meals) {
        totalCalories += meal.totalCalories;
        totalProtein += meal.totalProtein;
        totalCarbs += meal.totalCarbs;
        totalFat += meal.totalFat;
      }
      
      return {
        'calories': totalCalories,
        'protein': totalProtein,
        'carbs': totalCarbs,
        'fat': totalFat,
      };
    } catch (e) {
      print('Error getting total nutrition: $e');
      return {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fat': 0,
      };
    }
  }

  /// Clear all meals for a date
  Future<void> clearMealsForDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingMealsJson = prefs.getString(_mealsKey);
      
      if (existingMealsJson != null) {
        final List<dynamic> mealsList = json.decode(existingMealsJson);
        final allMeals = mealsList.map((meal) => Meal.fromJson(meal)).toList();
        
        // Remove meals for the specific date
        final dateKey = _getDateKey(date);
        allMeals.removeWhere((meal) => _getDateKey(meal.date) == dateKey);
        
        // Save updated meals
        final mealsJson = json.encode(allMeals.map((meal) => meal.toJson()).toList());
        await prefs.setString(_mealsKey, mealsJson);
      }
    } catch (e) {
      print('Error clearing meals: $e');
      throw Exception('Failed to clear meals');
    }
  }

  /// Get default empty meals for a date
  List<Meal> _getDefaultMeals(DateTime date) {
    return [
      Meal(type: MealType.breakfast, foodItems: [], date: date),
      Meal(type: MealType.lunch, foodItems: [], date: date),
      Meal(type: MealType.dinner, foodItems: [], date: date),
      Meal(type: MealType.snack, foodItems: [], date: date),
    ];
  }

  /// Get date key for comparison (YYYY-MM-DD format)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}