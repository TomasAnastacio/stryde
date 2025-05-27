import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import 'personal_data_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  
  // Método para registrar usuário com email e senha
  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      // Verificar se as senhas coincidem
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("As senhas não coincidem!"))
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Registrar com email e senha
        UserCredential userCredential = await _authService.registerWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        
        // Atualizar o nome do usuário
        await userCredential.user!.updateDisplayName(_nameController.text.trim());
        
        // Salvar dados básicos do usuário
        await _authService.saveUserData(
          userId: userCredential.user!.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );
        
        if (!mounted) return;
        
        // Navegar para a tela de dados pessoais
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PersonalDataScreen(),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        
        // Tratamento de erros específicos do Firebase
        String errorMessage = "Erro ao registrar";
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = "Este email já está sendo usado por outra conta.";
              break;
            case 'weak-password':
              errorMessage = "A senha fornecida é muito fraca.";
              break;
            case 'invalid-email':
              errorMessage = "O email fornecido é inválido.";
              break;
            default:
              errorMessage = "Erro ao registrar: ${e.message}";
          }
        } else {
          errorMessage = "Erro ao registrar: ${e.toString()}";
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage))
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  // Método para registrar com Google
  Future<void> _registerWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Login com Google
      UserCredential userCredential = await _authService.signInWithGoogle();
      
      if (!mounted) return;
      
      // Verificar se o perfil está completo
      bool hasCompletedProfile = await _authService.hasCompletedProfile(
        userCredential.user!.uid
      );
      
      if (!mounted) return;
      
      if (hasCompletedProfile) {
        // Navegar para a tela principal
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/home', 
          (route) => false
        );
      } else {
        // Navegar para a tela de dados pessoais
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PersonalDataScreen(),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao registrar com Google: ${e.toString()}"))
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          "Registar",
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
            // Ondas verdes no fundo - com bordas arredondadas no topo
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.local_fire_department,
                                    color: AppColors.white,
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "STRYDE",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40.0),
                          // Campo de nome
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: "Nome completo",
                              prefixIcon: const Icon(Icons.person, color: AppColors.primaryGreen),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, insira seu nome";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          // Campo de email
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: "Email",
                              prefixIcon: const Icon(Icons.email, color: AppColors.primaryGreen),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, insira seu email";
                              }
                              // Validação básica de email
                              if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                                return "Por favor, insira um email válido";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          // Campo de senha
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: "Senha",
                              prefixIcon: const Icon(Icons.lock, color: AppColors.primaryGreen),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                  color: AppColors.primaryGreen,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, insira uma senha";
                              }
                              if (value.length < 6) {
                                return "A senha deve ter pelo menos 6 caracteres";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25.0),
                          // Campo de confirmação de senha
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: "Confirmar senha",
                              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGreen),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                  color: AppColors.primaryGreen,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Por favor, confirme sua senha";
                              }
                              if (value != _passwordController.text) {
                                return "As senhas não coincidem";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 35),
                          // Botão de Registro
                          CustomButton(
                            text: _isLoading ? "Processando..." : "Registar",
                            onPressed: _isLoading ? null : () => _registerUser(),
                          ),
                          const SizedBox(height: 20),
                          
                          // Ou continue com
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Colors.grey)),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text("Ou continue com", style: TextStyle(color: Colors.grey)),
                              ),
                              const Expanded(child: Divider(color: Colors.grey)),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Botão de registro com Google
                          OutlinedButton.icon(
                            icon: Image.asset('assets/images/google_logo.png', height: 24),
                            label: const Text(
                              "Registar com Google",
                              style: TextStyle(color: Colors.black87),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            onPressed: _isLoading ? null : () => _registerWithGoogle(),
                          ),
                          
                          const SizedBox(height: 20),
                          // Link para Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Já tem uma conta? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Faça login",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryGreen,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}