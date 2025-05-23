import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';

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

  final List<String> _weightOptions = List.generate(101, (index) => '${40 + index} kg');
  final List<String> _heightOptions = List.generate(91, (index) => '${150 + index} cm');
  final List<String> _genderOptions = ['Masculino', 'Feminino', 'Outro'];
  final List<String> _goalOptions = ['Perder peso', 'Manter peso', 'Ganhar peso', 'Ganhar massa muscular'];

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
          ),
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Ondas verdes no topo
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
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
              SingleChildScrollView(
                child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
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
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
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
                      const SizedBox(height: 40),
                          
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
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
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
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
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
                      const SizedBox(height: 40),
                      
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
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
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
                                        filled: true,
                                        fillColor: Colors.grey[200],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(25),
                                          borderSide: BorderSide.none,
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
                      const SizedBox(height: 40),
                      
                      // Botão de Registro
                      CustomButton(
                        text: "Registar",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Processar os dados e calcular as necessidades calóricas
                            // Navegar para a próxima tela
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Dados salvos com sucesso!")),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
  );
  }
}