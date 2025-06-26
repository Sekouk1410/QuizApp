import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  Future<List<Map<String, dynamic>>> _getTopScores() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('scores')
        .orderBy('score', descending: true)
        .get();

    final seenUids = <String>{};
    final topUsers = <Map<String, dynamic>>[];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final uid = data['uid'];

      if (!seenUids.contains(uid)) {
        seenUids.add(uid);
        topUsers.add({
          'email': data['email'],
          'score': data['score'],
        });
      }

      if (topUsers.length == 10) break; // Top 10 uniquement
    }

    return topUsers;
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
