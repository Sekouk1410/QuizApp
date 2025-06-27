import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/screens/auth_screen.dart';
import 'quiz_screen.dart';
import 'score_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Color(0xFF77161F),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: Image.asset('assets/images/logo.png', width: 50, height: 50, fit: BoxFit.cover ,),
          ),
        ),
        title: Text('Faso Don', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Se déconnecter",
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Bienvenue dans le Quiz sur le Mali 🇲🇱",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user?.email ?? 'Utilisateur',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Le Mali, ses origines, son histoire… un quiz à la fois.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/imgAccueil.jpg',
                        height: 120,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              _buildMainButton(
                context,
                label: "Commencer le Quiz",
                icon: Icons.play_circle_fill,
                color: Colors.blueAccent,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                ),
              ),

              const SizedBox(height: 20),

              _buildMainButton(
                context,
                label: "Voir mes scores",
                icon: Icons.bar_chart,
                color: Colors.deepPurple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScoreScreen()),
                ),
              ),

              const SizedBox(height: 20),

              _buildMainButton(
                context,
                label: "Voir le classement",
                icon: Icons.leaderboard,
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 4,
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(double.infinity, 60),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 26),
      label: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }
}
