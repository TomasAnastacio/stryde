class UserModel {
  final String id;
  final String name;
  final String email;
  String? birthDate;
  double? weight;
  double? height;
  String? gender;
  String? goal;
  String? activityLevel;
  Map<String, dynamic>? nutritionPlan;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.birthDate,
    this.weight,
    this.height,
    this.gender,
    this.goal,
    this.activityLevel,
    this.nutritionPlan,
  });

  // Converter de Firestore para UserModel
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      birthDate: data['birthDate'],
      weight: data['weight']?.toDouble(),
      height: data['height']?.toDouble(),
      gender: data['gender'],
      goal: data['goal'],
      activityLevel: data['activityLevel'],
      nutritionPlan: data['nutritionPlan'],
    );
  }

  // Converter de UserModel para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'birthDate': birthDate,
      'weight': weight,
      'height': height,
      'gender': gender,
      'goal': goal,
      'activityLevel': activityLevel,
      'nutritionPlan': nutritionPlan,
    };
  }

  // Verificar se o perfil está completo
  bool get isProfileComplete {
    return weight != null &&
        height != null &&
        gender != null &&
        goal != null &&
        activityLevel != null;
  }

  // Criar uma cópia do modelo com novos valores
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? birthDate,
    double? weight,
    double? height,
    String? gender,
    String? goal,
    String? activityLevel,
    Map<String, dynamic>? nutritionPlan,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      nutritionPlan: nutritionPlan ?? this.nutritionPlan,
    );
  }
}