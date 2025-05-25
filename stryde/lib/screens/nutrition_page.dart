import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';
import 'food_search_screen.dart';
import 'profile_screen.dart';

class MainPageV3 extends StatefulWidget {
  const MainPageV3({Key? key}) : super(key: key);

  @override
  State<MainPageV3> createState() => _MainPageV3State();
}

class _MainPageV3State extends State<MainPageV3> {
  final MealService _mealService = MealService();
  List<Meal> _meals = [];
  Map<String, double> _totalNutrition = {
    'calories': 0,
    'protein': 0,
    'carbs': 0,
    'fat': 0,
  };
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final meals = await _mealService.getMealsForDate(_selectedDate);
      final nutrition = await _mealService.getTotalNutritionForDate(_selectedDate);
      
      setState(() {
        _meals = meals;
        _totalNutrition = nutrition;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar refeições: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToFoodSearch(MealType mealType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodSearchScreen(
          mealType: mealType,
          date: _selectedDate,
        ),
      ),
    );

    if (result == true) {
      _loadMeals(); // Reload meals after adding food
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    const weekdays = [
      'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    
    return '$weekday, $day de $month';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      );
    }

    final totalCalories = _totalNutrition['calories'] ?? 0;
    final totalProtein = _totalNutrition['protein'] ?? 0;
    final totalCarbs = _totalNutrition['carbs'] ?? 0;
    final totalFat = _totalNutrition['fat'] ?? 0;
    
    // Calculate progress (assuming daily goals)
    const dailyCalorieGoal = 2000.0;
    const dailyProteinGoal = 150.0;
    const dailyCarbGoal = 250.0;
    const dailyFatGoal = 65.0;
    
    final calorieProgress = (totalCalories / dailyCalorieGoal).clamp(0.0, 1.0);
    final proteinProgress = (totalProtein / dailyProteinGoal).clamp(0.0, 1.0);
    final carbProgress = (totalCarbs / dailyCarbGoal).clamp(0.0, 1.0);
    final fatProgress = (totalFat / dailyFatGoal).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with date and back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _formatDate(_selectedDate),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const Text(
                          'Suas refeições de hoje:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Date picker button
                  IconButton(
                    icon: const Icon(Icons.calendar_today, size: 20),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDate = date;
                        });
                        _loadMeals();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Calories and Macros Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Calories Circle
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: calorieProgress,
                            strokeWidth: 10,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryGreen),
                          ),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  totalCalories.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Cal',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Macros Progress
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMacroProgress(
                            'Proteínas',
                            proteinProgress,
                            Colors.blue,
                            '${(dailyProteinGoal - totalProtein).clamp(0, dailyProteinGoal).toStringAsFixed(0)}g restantes',
                          ),
                          const SizedBox(height: 12),
                          _buildMacroProgress(
                            'Carboidratos',
                            carbProgress,
                            Colors.orange,
                            '${(dailyCarbGoal - totalCarbs).clamp(0, dailyCarbGoal).toStringAsFixed(0)}g restantes',
                          ),
                          const SizedBox(height: 12),
                          _buildMacroProgress(
                            'Gorduras',
                            fatProgress,
                            Colors.red,
                            '${(dailyFatGoal - totalFat).clamp(0, dailyFatGoal).toStringAsFixed(0)}g restantes',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Meals Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _meals.map((meal) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildMealSection(meal),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroProgress(String title, double value, Color color, String remaining) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              remaining,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildMealSection(Meal meal) {
    final foodItems = meal.foodItems.map((mealFoodItem) {
      return _buildFoodItem(
        mealFoodItem.foodItem.name,
        mealFoodItem.displayPortion,
        mealFoodItem.totalCalories.toInt(),
      );
    }).toList();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  meal.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${meal.totalCalories.toStringAsFixed(0)} Cal',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [
                  ...foodItems,
                  _buildAddFoodButton(meal.type),
                ],
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(String name, String portion, int calories) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Porção: $portion',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$calories cal',
            style: const TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddFoodButton(MealType mealType) {
    return GestureDetector(
      onTap: () => _navigateToFoodSearch(mealType),
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.add_circle_outline,
          color: AppColors.primaryGreen,
          size: 32,
        ),
      ),
    );
  }
}