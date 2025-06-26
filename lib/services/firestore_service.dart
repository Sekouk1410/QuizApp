import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getQuestions(int count) async {
    try {
      final snapshot = await _db.collection('questions').get();

      if (snapshot.docs.isEmpty) {
        print("⚠️ Aucune question trouvée dans Firestore !");
      }

      final allQuestions = snapshot.docs.map((doc) => doc.data()).toList();
      allQuestions.shuffle();

      return allQuestions.take(count).toList();
    } catch (e) {
      print("❌ Erreur Firestore : $e");
      return []; // retourne une liste vide si erreur
    }
  }
    Future<void> saveUserScore(int score) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('scores').add({
      'uid': user.uid,
      'email': user.email,
      'score': score,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }


}
