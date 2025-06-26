import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  Future<List<Map<String, dynamic>>> _getTopScores() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('scores')
        .get(); // on récupère tout

    final Map<String, Map<String, dynamic>> bestScores = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final uid = data['uid'];
      final score = data['score'];

      // si l'utilisateur n'existe pas ou a un score inférieur, on garde le meilleur
      if (!bestScores.containsKey(uid) || bestScores[uid]!['score'] < score) {
        bestScores[uid] = {
          'email': data['email'],
          'score': score,
        };
      }
    }

    // convertir en liste, trier par score décroissant, et prendre les 10 meilleurs
    final topUsers = bestScores.values.toList()
      ..sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    return topUsers.take(10).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Top 10 des scores")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getTopScores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final scores = snapshot.data ?? [];

          if (scores.isEmpty) {
            return const Center(child: Text("Aucun score trouvé."));
          }

          return ListView.builder(
            itemCount: scores.length,
            itemBuilder: (ctx, index) {
              final user = scores[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text("${index + 1}", style: const TextStyle(color: Colors.white)),
                ),
                title: Text(user['email'] ?? "Utilisateur inconnu"),
                trailing: Text("${user['score']} / 10"),
              );
            },
          );
        },
      ),
    );
  }
}
