import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>(); // Pour valider le formulaire
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true; // Toggle entre inscription et connexion
  String errorMessage = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true; // On lance le loader
      errorMessage = '';
    });

    try {
      if (isLogin) {
        // Connexion
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        


      } else {
        // Inscription
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
      }

      if (!mounted) return; // On vérifie que le widget est encore "vivant"

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
      );

    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.message ?? "Erreur inconnue";
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // 🔁 On arrête le loader
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Formulaire validé avec ce key
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Image.asset(
                          'assets/images/logo.png',
                          height: 200,
                          width: 200,
                        ),
        
                        const  SizedBox(height: 10,),
                        Text('Faso Don', 
                        style: TextStyle(fontSize: 30, color: Color(0xFF77161F), fontWeight: FontWeight.w900),
                        ),
                        
        
                         const  SizedBox(height: 20,),
               TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            labelStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF77161F), width: 2),
            ),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) =>
        value == null || value.isEmpty ? 'Entrez un email' : null,
        ),
        
                const SizedBox(height: 10),
                // Mot de passe
                TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            labelStyle: const TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF77161F), width: 2),
            ),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
          validator: (value) =>
        value != null && value.length < 6 ? 'Minimum 6 caractères' : null,
        ),
        
                const SizedBox(height: 20),
        
                // Erreur si existante
                if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: const TextStyle(color: Colors.red)),
        
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  
                  style:  ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF77161F), // couleur de fond (bordeaux foncé)
                    foregroundColor: Colors.white, // couleur du texte
                     minimumSize: const Size(400, 50), // largeur: 200, hauteur: 50
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: Text(isLogin ? 'Se connecter' : "S'inscrire", style: TextStyle(color: Colors.white, fontSize: 20),),
                ),
        
             
                TextButton(
                  
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin
                      ? "Pas encore inscrit ? Créez un compte"
                      : "Déjà inscrit ? Connectez-vous"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
