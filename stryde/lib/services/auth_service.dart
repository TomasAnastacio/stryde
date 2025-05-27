import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obter usuário atual
  User? get currentUser => _auth.currentUser;

  // Stream para monitorar mudanças no estado de autenticação
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registrar com email e senha
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Login com email e senha
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Login com Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Iniciar o processo de login do Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Login com Google cancelado pelo usuário');
      }

      // Obter detalhes de autenticação da solicitação
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Criar credencial para o Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Fazer login no Firebase com a credencial do Google
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Verificar se é um novo usuário
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        // Salvar dados básicos do usuário no Firestore
        await saveUserData(
          userId: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? '',
          email: userCredential.user!.email ?? '',
        );
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Salvar dados do usuário no Firestore
  Future<void> saveUserData({
    required String userId,
    required String name,
    required String email,
    String? birthDate,
    double? weight,
    double? height,
    String? gender,
    String? goal,
    String? activityLevel,
    Map<String, dynamic>? nutritionPlan,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'birthDate': birthDate,
        'weight': weight,
        'height': height,
        'gender': gender,
        'goal': goal,
        'activityLevel': activityLevel,
        'nutritionPlan': nutritionPlan,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  // Verificar se o usuário já completou o perfil
  Future<bool> hasCompletedProfile(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;
      
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return data['weight'] != null && 
             data['height'] != null && 
             data['gender'] != null && 
             data['goal'] != null && 
             data['activityLevel'] != null &&
             data['nutritionPlan'] != null;
    } catch (e) {
      return false;
    }
  }
  
  // Obter dados do usuário
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      
      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  // Atualizar plano nutricional do usuário
  Future<void> updateNutritionPlan(String userId, Map<String, dynamic> nutritionPlan) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'nutritionPlan': nutritionPlan,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}