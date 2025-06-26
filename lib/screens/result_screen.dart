import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  const ResultScreen({super.key, required this.score});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveScore();
  }

  void _saveScore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final userScoreRef = FirebaseFirestore.instance.collection('leaderboard').doc(user.uid);

  final doc = await userScoreRef.get();

  if (!doc.exists || (doc.data()?['score'] ?? 0) < widget.score) {
      await userScoreRef.set({
        'uid': user.uid,
        'email': user.email,
        'score': widget.score,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Nouveau meilleur score enregistré");
    } else {
      print("Score non enregistré car moins bon que le précédent");
    }

    // Facultatif : tu peux aussi toujours enregistrer l'historique dans "scores"
    await FirebaseFirestore.instance.collection('scores').add({
      'uid': user.uid,
      'email': user.email,
      'score': widget.score,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.score >= 5 ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                size: 80,
                color: widget.score >= 5 ? Colors.amber : Colors.blueAccent,
              ),
              const SizedBox(height: 24),
              Text(
                widget.score >= 5 ? 'Bravo !' : 'Dommage...',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Votre score : ${widget.score} / 10",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => const HomeScreen(),
                        transitionsBuilder: (_, a, __, c) =>
                            FadeTransition(opacity: a, child: c),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Retour à l'accueil",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}