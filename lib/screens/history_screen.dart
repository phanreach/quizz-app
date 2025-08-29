import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _categories = [
    'All',
    'General Knowledge',
    'IQ Test',
    'EQ Test',
    'World History Test',
    'Khmer History Test',
    'Englsih Grammar Test',
    'Math Test',
    'Physics Test'
  ];

  // Sample test history data
  final List<TestHistory> _testHistory = [
    TestHistory(
      id: 1,
      category: 'General Knowledge',
      title: 'General Knowledge Test #1',
      score: 8,
      totalQuestions: 10,
      percentage: 80,
      dateTaken: DateTime.now().subtract(const Duration(days: 1)),
      duration: '5:30',
      questions: [
        QuestionHistory(
          question: 'What is the capital of France?',
          options: ['London', 'Berlin', 'Paris', 'Madrid'],
          correctAnswer: 'Paris',
          userAnswer: 'Paris',
          isCorrect: true,
        ),
        QuestionHistory(
          question: 'Which planet is known as the Red Planet?',
          options: ['Venus', 'Mars', 'Jupiter', 'Saturn'],
          correctAnswer: 'Mars',
          userAnswer: 'Mars',
          isCorrect: true,
        ),
        QuestionHistory(
          question: 'Who painted the Mona Lisa?',
          options: ['Van Gogh', 'Picasso', 'Da Vinci', 'Monet'],
          correctAnswer: 'Da Vinci',
          userAnswer: 'Picasso',
          isCorrect: false,
        ),
      ],
    ),
    TestHistory(
      id: 2,
      category: 'IQ Test',
      title: 'IQ Test #1',
      score: 7,
      totalQuestions: 10,
      percentage: 70,
      dateTaken: DateTime.now().subtract(const Duration(days: 3)),
      duration: '7:15',
      questions: [
        QuestionHistory(
          question: 'What is H2O?',
          options: ['Oxygen', 'Hydrogen', 'Water', 'Carbon'],
          correctAnswer: 'Water',
          userAnswer: 'Water',
          isCorrect: true,
        ),
        QuestionHistory(
          question: 'What is the speed of light?',
          options: [
            '300,000 km/s',
            '150,000 km/s',
            '450,000 km/s',
            '200,000 km/s'
          ],
          correctAnswer: '300,000 km/s',
          userAnswer: '150,000 km/s',
          isCorrect: false,
        ),
      ],
    ),
    TestHistory(
      id: 3,
      category: 'Math',
      title: 'Math Challenge #1',
      score: 9,
      totalQuestions: 10,
      percentage: 90,
      dateTaken: DateTime.now().subtract(const Duration(days: 7)),
      duration: '4:45',
      questions: [
        QuestionHistory(
          question: 'What is 15 × 8?',
          options: ['120', '125', '130', '115'],
          correctAnswer: '120',
          userAnswer: '120',
          isCorrect: true,
        ),
      ],
    ),
    TestHistory(
      id: 4,
      category: 'World History Test',
      title: 'World History Quiz',
      score: 6,
      totalQuestions: 10,
      percentage: 60,
      dateTaken: DateTime.now().subtract(const Duration(days: 10)),
      duration: '8:20',
      questions: [
        QuestionHistory(
          question: 'When did World War II end?',
          options: ['1944', '1945', '1946', '1947'],
          correctAnswer: '1945',
          userAnswer: '1944',
          isCorrect: false,
        ),
      ],
    ),
  ];

  List<TestHistory> get filteredHistory {
    if (_selectedFilter == 'All') {
      return _testHistory;
    }
    return _testHistory.where((test) => test.category == _selectedFilter).toList();
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF10B981);
    if (percentage >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildFilterSection(),
            Expanded(
              child: filteredHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(),
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
              'History',
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

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF6366F1).withOpacity(0.1),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.history_outlined,
                size: 40,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No test history found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complete a quiz to see your history here',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: filteredHistory.length,
      itemBuilder: (context, index) {
        final test = filteredHistory[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TestDetailScreen(testHistory: test),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                test.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                test.category,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getScoreColor(test.percentage).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${test.percentage}%',
                            style: TextStyle(
                              color: _getScoreColor(test.percentage),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: const Color(0xFFE2E8F0),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: _getScoreColor(test.percentage),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${test.score}/${test.totalQuestions} correct',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          test.duration,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TestDetailScreen extends StatelessWidget {
  final TestHistory testHistory;

  const TestDetailScreen({super.key, required this.testHistory});

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return const Color(0xFF10B981);
    if (percentage >= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTestSummaryCard(),
                    const SizedBox(height: 32),
                    const Text(
                      'Your Answers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: testHistory.questions.length,
                      itemBuilder: (context, index) {
                        final question = testHistory.questions[index];
                        return _buildQuestionCard(question, index + 1);
                      },
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

  Widget _buildAppBar(BuildContext context) {
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
              'Test Details',
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

  Widget _buildTestSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getScoreColor(testHistory.percentage).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            testHistory.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            testHistory.category,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Score',
                '${testHistory.score}/${testHistory.totalQuestions}',
                Icons.star_border,
                _getScoreColor(testHistory.percentage),
              ),
              _buildSummaryItem(
                'Percentage',
                '${testHistory.percentage}%',
                Icons.bar_chart,
                _getScoreColor(testHistory.percentage),
              ),
              _buildSummaryItem(
                'Duration',
                testHistory.duration,
                Icons.access_time_outlined,
                const Color(0xFF6366F1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionHistory question, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $index',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: question.isCorrect
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      question.isCorrect ? Icons.check_circle : Icons.cancel,
                      size: 14,
                      color: question.isCorrect
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      question.isCorrect ? 'Correct' : 'Incorrect',
                      style: TextStyle(
                        fontSize: 12,
                        color: question.isCorrect
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ...question.options.asMap().entries.map((entry) {
            int optionIndex = entry.key;
            String option = entry.value;
            bool isCorrect = option == question.correctAnswer;
            bool isUserAnswer = option == question.userAnswer;

            Color backgroundColor = Colors.white;
            Color borderColor = const Color(0xFFE2E8F0);
            Color textColor = const Color(0xFF1E293B);
            FontWeight fontWeight = FontWeight.w400;
            Widget? trailing;

            if (isCorrect) {
              backgroundColor = const Color(0xFF10B981).withOpacity(0.05);
              borderColor = const Color(0xFF10B981);
              textColor = const Color(0xFF065F46);
              fontWeight = FontWeight.w600;
              trailing = const Icon(
                Icons.check_circle,
                color: Color(0xFF10B981),
                size: 20,
              );
            } else if (isUserAnswer) {
              backgroundColor = const Color(0xFFEF4444).withOpacity(0.05);
              borderColor = const Color(0xFFEF4444);
              textColor = const Color(0xFF991B1B);
              fontWeight = FontWeight.w600;
              trailing = const Icon(
                Icons.cancel,
                color: Color(0xFFEF4444),
                size: 20,
              );
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border.all(color: borderColor, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '${String.fromCharCode(65 + optionIndex)}. ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: fontWeight,
                      color: textColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: fontWeight,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
class TestHistory {
  final int id;
  final String category;
  final String title;
  final int score;
  final int totalQuestions;
  final int percentage;
  final DateTime dateTaken;
  final String duration;
  final List<QuestionHistory> questions;

  TestHistory({
    required this.id,
    required this.category,
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.dateTaken,
    required this.duration,
    required this.questions,
  });
}

class QuestionHistory {
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String userAnswer;
  final bool isCorrect;

  QuestionHistory({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.userAnswer,
    required this.isCorrect,
  });
}