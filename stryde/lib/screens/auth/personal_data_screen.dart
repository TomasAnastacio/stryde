import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/nutrition_calculator_service.dart';
import '../../services/auth_service.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({Key? key}) : super(key: key);

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  String? _selectedWeight;
  String? _selectedHeight;
  String? _selectedGender;
  String? _selectedGoal;
  String? _selectedActivityLevel;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  final List<String> _weightOptions = List.generate(101, (index) => '${40 + index} kg');
  final List<String> _heightOptions = List.generate(91, (index) => '${150 + index} cm');
  final List<String> _genderOptions = ['Masculino', 'Feminino', 'Outro'];
  final List<String> _goalOptions = ['Perder peso', 'Manter peso', 'Ganhar peso', 'Ganhar massa muscular'];
  final List<String> _activityOptions = ['Sedentário', 'Levemente ativo', 'Moderadamente ativo', 'Muito ativo', 'Extremamente ativo'];

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _processUserData() async {
    if (_authService.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Você precisa estar logado para continuar."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Extrair valores dos campos
      double weight = double.parse(_selectedWeight!.replaceAll(' kg', ''));
      double height = double.parse(_selectedHeight!.replaceAll(' cm', ''));
      
      // Converter data de nascimento
      List<String> dateParts = _dateController.text.split(' / ');
      DateTime birthDate = DateTime(
        int.parse(dateParts[2]), // ano
        int.parse(dateParts[1]), // mês
        int.parse(dateParts[0]), // dia
      );
      
      int age = NutritionCalculatorService.calculateAge(birthDate);
      
      // Validar dados
      bool isValid = NutritionCalculatorService.validateInputs(
        weight: weight,
        height: height,
        birthDate: birthDate,
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
        goal: _selectedGoal,
      );
      
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Dados inválidos. Verifique as informações inseridas."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Calcular plano nutricional
      Map<String, double> nutritionPlan = NutritionCalculatorService.calculateNutritionPlan(
        weight: weight,
        height: height,
        age: age,
        gender: _selectedGender!,
        activityLevel: _selectedActivityLevel!,
        goal: _selectedGoal!,
      );
      
      // Salvar dados do usuário no Firebase
      await _authService.saveUserData(
        userId: _authService.currentUser!.uid,
        name: _authService.currentUser!.displayName ?? '',
        email: _authService.currentUser!.email ?? '',
        birthDate: _dateController.text,
        weight: weight,
        height: height,
        gender: _selectedGender,
        goal: _selectedGoal,
        activityLevel: _selectedActivityLevel,
        nutritionPlan: nutritionPlan,
      );
      
      // Mostrar resultados
      _showNutritionResults(nutritionPlan);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao processar dados: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  void _showNutritionResults(Map<String, double> nutritionPlan) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Seu Plano Nutricional",
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNutritionRow("Taxa Metabólica Basal (TMB)", "${nutritionPlan['bmr']!.toInt()} kcal"),
                _buildNutritionRow("Gasto Calórico Diário (TDEE)", "${nutritionPlan['tdee']!.toInt()} kcal"),
                const Divider(color: AppColors.primaryGreen),
                const Text(
                  "Necessidades Diárias:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                _buildNutritionRow("Calorias", "${nutritionPlan['calories']!.toInt()} kcal"),
                _buildNutritionRow("Proteínas", "${nutritionPlan['protein']!.toInt()} g"),
                _buildNutritionRow("Gorduras", "${nutritionPlan['fat']!.toInt()} g"),
                _buildNutritionRow("Carboidratos", "${nutritionPlan['carbs']!.toInt()} g"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Aqui você pode navegar para a próxima tela ou salvar no Firebase
                _saveToFirebase(nutritionPlan);
              },
              child: const Text(
                "Continuar",
                style: TextStyle(color: AppColors.primaryGreen),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildNutritionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
  
  void _saveToFirebase(Map<String, double> nutritionPlan) {
    // TODO: Implementar salvamento no Firebase
    // Por agora, apenas mostra uma mensagem de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Dados salvos com sucesso!"),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
    
    // Navegar de volta ou para a próxima tela
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Dados Pessoais",
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ondas verdes no topo
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 110,
                margin: const EdgeInsets.only(bottom: 100.0),
                decoration: const BoxDecoration(
                   color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
            // Ondas verdes no fundo
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
              ),
            ),
            // Conteúdo principal
            Positioned(
              top: 100,
              bottom: 100,
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        // Data de nascimento
                        const Text(
                          "Data de nascimento",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            hintText: "DD / MM / YYYY",
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Por favor, insira sua data de nascimento";
                            }
                            return null;
                          },
                          onTap: () async {
                            // Esconde o teclado
                            FocusScope.of(context).requestFocus(FocusNode());
                            
                            // Mostra o date picker
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                              firstDate: DateTime(1940),
                              lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: AppColors.primaryGreen,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          
                          if (picked != null) {
                            setState(() {
                              _dateController.text = "${picked.day.toString().padLeft(2, '0')} / ${picked.month.toString().padLeft(2, '0')} / ${picked.year}";
                            });
                          }
                        },
                      ),
                        const SizedBox(height: 30),
                          
                        // Peso e Altura (em linha)
                        Row(
                          children: [
                            // Peso
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Peso",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _selectedWeight,
                                      decoration: InputDecoration(
                                        filled: false,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                                        ),
                                      ),
                                      items: _weightOptions.map((weight) {
                                        return DropdownMenuItem<String>(
                                          value: weight,
                                          child: Text(weight),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedWeight = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Selecione o peso";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Altura
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Altura",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _selectedHeight,
                                      decoration: InputDecoration(
                                        filled: false,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                                        ),
                                      ),
                                      items: _heightOptions.map((height) {
                                        return DropdownMenuItem<String>(
                                          value: height,
                                          child: Text(height),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedHeight = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Selecione a altura";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 30),
                      
                        // Sexo e Meta (em linha)
                        Row(
                          children: [
                            // Sexo
                            Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                    const Text(
                                      "Sexo",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _selectedGender,
                                      decoration: InputDecoration(
                                        filled: false,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                                        ),
                                      ),
                                      items: _genderOptions.map((gender) {
                                        return DropdownMenuItem<String>(
                                          value: gender,
                                          child: Text(gender),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Selecione o sexo";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Meta
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Meta",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: _selectedGoal,
                                      decoration: InputDecoration(
                                        filled: false,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                                        ),
                                      ),
                                      items: _goalOptions.map((goal) {
                                        return DropdownMenuItem<String>(
                                          value: goal,
                                          child: Text(goal),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGoal = value;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Selecione a meta";
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 30),
                      
                        // Nível de Atividade Física
                        const Text(
                          "Nível de Atividade Física",
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedActivityLevel,
                          decoration: InputDecoration(
                            filled: false,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                            ),
                          ),
                          items: _activityOptions.map((activity) {
                            return DropdownMenuItem<String>(
                              value: activity,
                              child: Text(activity),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedActivityLevel = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Selecione o nível de atividade";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),
                        
                        // Botão de registro
                        CustomButton(
                          text: "Registar",
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _processUserData();
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            )
            ],
          ),
        ),
      );
  }
}