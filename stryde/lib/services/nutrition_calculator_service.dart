class NutritionCalculatorService {
  // Níveis de atividade física
  static const Map<String, double> activityFactors = {
    'Sedentário': 1.2,
    'Levemente ativo': 1.375,
    'Moderadamente ativo': 1.55,
    'Muito ativo': 1.725,
    'Extremamente ativo': 1.9,
  };

  // Calcular Taxa Metabólica Basal usando fórmula de Mifflin-St Jeor
  static double calculateBMR({
    required double weight, // kg
    required double height, // cm
    required int age, // anos
    required String gender,
  }) {
    if (gender.toLowerCase() == 'masculino') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  // Calcular Gasto Calórico Diário
  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    double factor = activityFactors[activityLevel] ?? 1.2;
    return bmr * factor;
  }

  // Ajustar calorias conforme a meta
  static double adjustCaloriesForGoal({
    required double tdee,
    required String goal,
  }) {
    switch (goal.toLowerCase()) {
      case 'perder peso':
        return tdee * 0.8;
      case 'ganhar peso':
      case 'ganhar massa muscular':
        return tdee * 1.15;
      case 'manter peso':
      default:
        return tdee;
    }
  }

  // Calcular distribuição de macronutrientes
  static Map<String, double> calculateMacros({
    required double weight, // kg
    required double totalCalories,
    required String goal,
  }) {
    // Proteínas: 2g por kg de peso corporal
    double proteinGrams = weight * 2;
    double proteinCalories = proteinGrams * 4;

    // Gorduras: 25% das calorias totais
    double fatCalories = totalCalories * 0.25;
    double fatGrams = fatCalories / 9;

    // Carboidratos: restante das calorias
    double carbCalories = totalCalories - (proteinCalories + fatCalories);
    double carbGrams = carbCalories / 4;

    return {
      'calories': totalCalories.round().toDouble(),
      'protein': proteinGrams.round().toDouble(),
      'fat': fatGrams.round().toDouble(),
      'carbs': carbGrams.round().toDouble(),
    };
  }

  // Função principal que calcula tudo
  static Map<String, double> calculateNutritionPlan({
    required double weight, // kg
    required double height, // cm
    required int age, // anos
    required String gender,
    required String activityLevel,
    required String goal,
  }) {
    // 1. Calcular TMB
    double bmr = calculateBMR(
      weight: weight,
      height: height,
      age: age,
      gender: gender,
    );

    // 2. Calcular TDEE
    double tdee = calculateTDEE(
      bmr: bmr,
      activityLevel: activityLevel,
    );

    // 3. Ajustar para meta
    double targetCalories = adjustCaloriesForGoal(
      tdee: tdee,
      goal: goal,
    );

    // 4. Calcular macros
    Map<String, double> macros = calculateMacros(
      weight: weight,
      totalCalories: targetCalories,
      goal: goal,
    );

    // Adicionar informações extras
    macros['bmr'] = bmr.round().toDouble();
    macros['tdee'] = tdee.round().toDouble();

    return macros;
  }

  // Calcular idade a partir da data de nascimento
  static int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  // Validar dados de entrada
  static bool validateInputs({
    required double? weight,
    required double? height,
    required DateTime? birthDate,
    required String? gender,
    required String? activityLevel,
    required String? goal,
  }) {
    if (weight == null || weight <= 0) return false;
    if (height == null || height <= 0) return false;
    if (birthDate == null) return false;
    if (gender == null || gender.isEmpty) return false;
    if (activityLevel == null || !activityFactors.containsKey(activityLevel)) return false;
    if (goal == null || goal.isEmpty) return false;
    
    int age = calculateAge(birthDate);
    if (age < 10 || age > 120) return false;
    
    return true;
  }
}