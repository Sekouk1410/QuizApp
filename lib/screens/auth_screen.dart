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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (isLogin) {
        // Connexion
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );


      } else {
        // Inscription
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );

      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "Erreur inconnue";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Connexion' : 'Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Formulaire validé avec ce key
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Entrez un email' : null,
              ),
              const SizedBox(height: 10),
              // Mot de passe
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Minimum 6 caractères' : null,
              ),
              const SizedBox(height: 20),

              // Erreur si existante
              if (errorMessage.isNotEmpty)
                Text(errorMessage, style: const TextStyle(color: Colors.red)),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isLogin ? 'Se connecter' : "S'inscrire"),
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
    );
  }
}
