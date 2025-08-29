import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../utils/app_logger.dart';

class QuizScreen extends StatefulWidget {
  final List<dynamic> questions;
  final String? categoryName;
  final int? categoryId;

  const QuizScreen({
    super.key,
    required this.questions,
    this.categoryName,
    this.categoryId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  Map<int, String> answers = {};
  int timer = 15;
  Timer? countdown;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    startTimer();
  }

  void startTimer() {
    countdown?.cancel();
    timer = 15;
    countdown = Timer.periodic(const Duration(seconds: 1), (timerTick) {
      if (mounted) {
        setState(() {
          if (timer > 0) {
            timer--;
          } else {
            timerTick.cancel();
            nextQuestion();
          }
        });
      }
    });
  }

  void nextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      finishQuiz();
    }
  }

  void finishQuiz() {
    countdown?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          answers: answers,
          questions: widget.questions,
          categoryId: widget.categoryId,
        ),
      ),
    );
  }

  void selectAnswer(String answer) {
    setState(() {
      answers[widget.questions[currentIndex]['id']] = answer;
    });
    // Automatically move to the next question after a slight delay
    Future.delayed(const Duration(milliseconds: 300), () {
      nextQuestion();
    });
  }

  @override
  void dispose() {
    countdown?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildProgressIndicator(),
            _buildTimerAndQuestionInfo(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.questions.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                  startTimer();
                },
                itemBuilder: (context, index) {
                  final question = widget.questions[index];
                  return _buildQuestionCard(question);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A6366F1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.categoryName != null
                  ? '${widget.categoryName} Quiz'
                  : 'Quiz',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      height: 6,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: (currentIndex + 1) / widget.questions.length,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerAndQuestionInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(text: "Question "),
                TextSpan(
                  text: "${currentIndex + 1}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                TextSpan(
                  text: "/${widget.questions.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    value: timer / 15,
                    strokeWidth: 3,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                  ),
                ),
                Text(
                  "$timer",
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(dynamic question) {
    List<dynamic> options = question['optionEn'] ?? question['options'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              question['questionEn'] ?? question['question'] ?? 'Question not available',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(options.length, (i) {
            String opt = options[i]?.toString() ?? '';
            bool isSelected = answers[question['id']] == opt;
            return _buildOptionCard(opt, isSelected, question['id']);
          }),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String option, bool isSelected, int questionId) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => selectAnswer(option),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? const Color(0xFF6366F1).withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 12 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Result Screen
class ResultScreen extends StatefulWidget {
  final Map<int, String> answers;
  final List<dynamic> questions;
  final int? categoryId;

  const ResultScreen({
    super.key,
    required this.answers,
    required this.questions,
    this.categoryId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _submitMessage;

  @override
  Widget build(BuildContext context) {
    int correct = 0;
    for (var q in widget.questions) {
      String correctAnswer = q['answerCode'] ?? q['answer'] ?? '';
      if (widget.answers[q['id']] == correctAnswer) correct++;
    }

    double scorePercent = (correct / widget.questions.length) * 100;
    Color scoreColor = scorePercent >= 70
        ? const Color(0xFF10B981)
        : scorePercent >= 40
        ? const Color(0xFFF59E0B)
        : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: scoreColor.withOpacity(0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Quiz Completed!",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Score Circle
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 140,
                                height: 140,
                                child: CircularProgressIndicator(
                                  value: scorePercent / 100,
                                  strokeWidth: 8,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  valueColor: AlwaysStoppedAnimation(scoreColor),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "${scorePercent.toInt()}%",
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: scoreColor,
                                    ),
                                  ),
                                  Text(
                                    "$correct/${widget.questions.length}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "You got $correct out of ${widget.questions.length} questions correct.",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submission Status
                    if (_submitMessage != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: _isSubmitted ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isSubmitted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isSubmitted ? Icons.check_circle : Icons.error,
                              color: _isSubmitted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _submitMessage!,
                                style: TextStyle(
                                  color: _isSubmitted ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Action Buttons
                    if (!_isSubmitted)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitResults,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                            disabledBackgroundColor: const Color(0xFF6366F1).withOpacity(0.5),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "Submit Results",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6366F1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFF6366F1), width: 1),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          "Back to Home",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
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

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A6366F1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Results",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitResults() async {
    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
    });

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        setState(() {
          _isSubmitting = false;
          _submitMessage = 'Please login to submit results';
        });
        return;
      }

      int correct = 0;
      for (var q in widget.questions) {
        String correctAnswer = q['answerCode'] ?? q['answer'] ?? '';
        if (widget.answers[q['id']] == correctAnswer) correct++;
      }

      final result = await ApiService.submitQuiz(
        categoryId: widget.questions.isNotEmpty ? (widget.questions[0]['categoryId'] ?? widget.categoryId ?? 1) : 1,
        totalQuestions: widget.questions.length,
        totalCorrect: correct,
        token: token,
      );

      AppLogger.info("🎯 Quiz Submit Response: ", result);

      final apiScore = result['score'];
      final submittedCorrect = result['totalCorrect'];
      final submittedTotal = result['totalQuestion'];

      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;
        _submitMessage =
        'Results submitted successfully!\nScore: $apiScore%\n($submittedCorrect/$submittedTotal correct)';
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _submitMessage = "Failed to submit results: ${e.toString()}";
      });
    }
  }
}