import 'package:flutter/material.dart';
import 'package:quiz_app/services/firestore_service.dart';
import 'result_screen.dart';
import 'dart:async';


class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = true;
  bool _answered = false;
  String? _selectedAnswer;
  double _progress = 1.0;
  int _timeLeft = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    debugPrint("Chargement des questions...");
    try {
      final questions = await _firestoreService.getQuestions(10);
      print("Questions reçues : ${questions.length}");

      if (!mounted) return;

      if (questions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Aucune question trouvée. Veuillez réessayer plus tard."),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() {
          _isLoading = false;
          _questions = [];
        });
        return;
      }

      setState(() {
        _questions = questions;
        _isLoading = false;
      });

      _startTimer();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur de chargement: ${e.toString()}"),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        _isLoading = false;
        _questions = [];
      });
    }
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    
    _timer?.cancel();
    final correct = _questions[_currentIndex]['correctAnswer'];
    
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == correct) _score++;
    });

    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  Future<void> _nextQuestion() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedAnswer = null;
        _timeLeft = 10;
        _progress = 1.0;
      });
      _startTimer();
    } else {
      _timer?.cancel();
      await _firestoreService.saveUserScore(_score);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(score: _score),
        ),
      );
    }
  }

  void _startTimer() {
    _timeLeft = 10;
    _progress = 1.0;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_timeLeft == 0) {
        _handleTimeout();
        timer.cancel();
      } else {
        setState(() {
          _timeLeft--;
          _progress = _timeLeft / 10;
        });
      }
    });
  }

  void _handleTimeout() {
    if (!mounted) return;
    
    setState(() {
      _answered = true;
      _selectedAnswer = null;
    });

    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

 // [Le reste du code reste inchangé jusqu'à la méthode build]

@override
Widget build(BuildContext context) {
  if (_isLoading) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF77161F),
              strokeWidth: 4,
            ),
            const SizedBox(height: 20),
            Text(
              "Chargement des questions...",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  if (_questions.isEmpty) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Quiz',style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF77161F),
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left, color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.red[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Aucune question disponible',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Veuillez réessayer plus tard',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _questions = [];
                  });
                  _loadQuestions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF77161F),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Réessayer', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final question = _questions[_currentIndex];
  final options = List<String>.from(question['options']);

  return Scaffold(
    backgroundColor: Colors.grey[50],
    appBar: AppBar(
      title: Text('Question ${_currentIndex + 1}/${_questions.length}', style: TextStyle(color: Colors.white),),
      backgroundColor: Color(0xFF77161F),
      leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left, color: Colors.white),
        ),
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Score: $_score',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
            color: _timeLeft <= 3 ? Colors.red : Color(0xFF77161F),
            backgroundColor: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 24),
          Text(
            question['question'],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: options.map((option) {
                final isCorrect = option == question['correctAnswer'];
                final isSelected = option == _selectedAnswer;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    borderRadius: BorderRadius.circular(12),
                    color: _answered
                        ? isCorrect
                            ? Colors.green[400]
                            : isSelected
                                ? Colors.red[300]
                                : Colors.grey[200]
                        : Colors.white,
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _selectAnswer(option),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            if (_answered && isSelected)
                              Icon(
                                isCorrect ? Icons.check : Icons.close,
                                color: isCorrect ? Colors.green[800] : Colors.red[800],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (!_answered)
            Center(
              child: Text(
                'Temps restant: $_timeLeft secondes',
                style: TextStyle(
                  fontSize: 16,
                  color: _timeLeft <= 3 ? Colors.red : Color(0xFF77161F),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
}