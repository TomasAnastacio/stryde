import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../models/meal.dart';
import '../services/fatsecret_service.dart';
import '../services/meal_service.dart';
import '../utils/constants.dart';
import 'food_details_screen.dart';

class FoodSearchScreen extends StatefulWidget {
  final MealType mealType;
  final DateTime date;

  const FoodSearchScreen({
    Key? key,
    required this.mealType,
    required this.date,
  }) : super(key: key);

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FatSecretService _fatSecretService = FatSecretService();
  final MealService _mealService = MealService();
  
  List<FoodItem> _searchResults = [];
  List<String> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.length >= 2) {
      _getAutocompleteSuggestions(query);
    } else {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  Future<void> _getAutocompleteSuggestions(String query) async {
    try {
      final suggestions = await _fatSecretService.getAutocompleteSuggestions(query);
      setState(() {
        _suggestions = suggestions.take(5).toList();
        _showSuggestions = suggestions.isNotEmpty;
      });
    } catch (e) {
      // Silently handle autocomplete errors
    }
  }

  Future<void> _searchFoods(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _showSuggestions = false;
    });

    try {
      final results = await _fatSecretService.searchFoods(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error searching foods: ${e.toString()}';
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  Future<void> _addFoodToMeal(FoodItem foodItem) async {
    try {
      // Navigate to food details screen to select serving size
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodDetailsScreen(
            foodItem: foodItem,
            mealType: widget.mealType,
            date: widget.date,
          ),
        ),
      );

      if (result == true) {
        // Food was added successfully, go back to nutrition page
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding food: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getMealDisplayName() {
    switch (widget.mealType) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Adicionar a ${_getMealDisplayName()}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Pesquisar alimentos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchResults = [];
                                _suggestions = [];
                                _showSuggestions = false;
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  onSubmitted: _searchFoods,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _searchFoods(_searchController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Pesquisar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Suggestions
          if (_showSuggestions && _suggestions.isNotEmpty)
            Container(
              color: Colors.white,
              child: Column(
                children: _suggestions.map((suggestion) {
                  return ListTile(
                    leading: const Icon(Icons.search, color: Colors.grey),
                    title: Text(suggestion),
                    onTap: () {
                      _searchController.text = suggestion;
                      _searchFoods(suggestion);
                    },
                  );
                }).toList(),
              ),
            ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _searchFoods(_searchController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                ),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Pesquise por alimentos para adicionar à sua refeição',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final food = _searchResults[index];
        return _buildFoodItem(food);
      },
    );
  }

  Widget _buildFoodItem(FoodItem food) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          food.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (food.brand.isNotEmpty)
              Text(
                food.brand,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              '${food.calories.toStringAsFixed(0)} cal por porção',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.add_circle,
            color: AppColors.primaryGreen,
            size: 32,
          ),
          onPressed: () => _addFoodToMeal(food),
        ),
        onTap: () => _addFoodToMeal(food),
      ),
    );
  }
}