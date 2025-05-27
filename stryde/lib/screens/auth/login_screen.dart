import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import 'personal_data_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  void _handleSignIn() {
  if (!_isLoading) {
    _signIn();
  }
}

  // Método para fazer login com email e senha
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Login com email e senha
        await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        
        if (!mounted) return;
        
        // Verificar se o perfil está completo
        bool hasCompletedProfile = await _authService.hasCompletedProfile(
          _authService.currentUser!.uid
        );
        
        if (!mounted) return;
        
        if (hasCompletedProfile) {
          // Navegar para a tela principal
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/home', 
            (route) => false
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login realizado com sucesso!"))
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
          SnackBar(content: Text("Erro ao fazer login: ${e.toString()}"))
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

  // Método para fazer login com Google
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Login com Google
      await _authService.signInWithGoogle();
      
      if (!mounted) return;
      
      // Verificar se o perfil está completo
      bool hasCompletedProfile = await _authService.hasCompletedProfile(
        _authService.currentUser!.uid
      );
      
      if (!mounted) return;
      
      if (hasCompletedProfile) {
        // Navegar para a tela principal
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/home', 
          (route) => false
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login realizado com sucesso!"))
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
        SnackBar(content: Text("Erro ao fazer login com Google: ${e.toString()}"))
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
    _emailController.dispose();
    _passwordController.dispose();
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
          "Login",
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
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                    // Campo de email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email, color: AppColors.primaryGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: AppColors.primaryGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira seu email";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),
                    // Campo de senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Senha",
                        prefixIcon: const Icon(Icons.lock, color: AppColors.primaryGreen),
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
                          borderSide: const BorderSide(color: AppColors.primaryGreen),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor, insira sua senha";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    // Link para recuperar senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // Navegação para a tela de recuperação de senha
                        },
                        child: const Text(
                          "Esqueceu a senha?",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryGreen,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Botão de Login
                    CustomButton(
                      text: _isLoading ? "Processando..." : "Entrar",
                      onPressed: _isLoading ? null : _handleSignIn,
                    ),
                    
                    const SizedBox(height: 20.0),
                    
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
                    
                    const SizedBox(height: 20.0),
                    
                    // Botão de login com Google
                    OutlinedButton.icon(
                      icon: Image.asset('assets/images/google_logo.png', height: 24),
                      label: const Text(
                        "Entrar com Google",
                        style: TextStyle(color: Colors.black87),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: _isLoading ? null : _signInWithGoogle,
                    ),
                    const SizedBox(height: 20.0),
                    // Link para registro
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Não tem uma conta? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Registre-se",
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}