import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/home_data.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../utils/app_logger.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _languageCode = 'en';
  final List<String> _languages = ['en', 'zh', 'kh'];
  int _currentLanguageIndex = 0;

  final PageController _bannerPageController = PageController(viewportFraction: 0.9);
  int _currentBannerIndex = 0;

  HomeData? _homeData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
    _bannerPageController.addListener(() {
      setState(() {
        _currentBannerIndex = _bannerPageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    super.dispose();
  }

  void _switchLanguage() {
    setState(() {
      _currentLanguageIndex = (_currentLanguageIndex + 1) % _languages.length;
      _languageCode = _languages[_currentLanguageIndex];
    });
  }

  Future<void> _fetchHomeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final homeDataMap = await ApiService.fetchHomeData();

      setState(() {
        _homeData = HomeData(
          categories: homeDataMap['categories'] as List<Category>,
          banners: homeDataMap['banners'] as List<BannerItem>,
          promotions: homeDataMap['promotions'] as List<Promotion>,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _homeData = _createMockData();
        _isLoading = false;
        _errorMessage = 'Failed to fetch home data. Using mock data.';
      });
      AppLogger.warning('Failed to fetch home data, using mock data', e);
    }
  }

  HomeData _createMockData() {
    return HomeData(
      categories: [
        Category(
          id: 1,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/general-test.png',
          nameEn: 'General Knowledge',
          nameZh: '常识',
          nameKh: 'ចំណេះដឹងទូទៅ',
        ),
        Category(
          id: 2,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/iq-test.png',
          nameEn: 'IQ Test',
          nameZh: '智商测试',
          nameKh: 'តេស្តវិឆ័យបញ្ញា',
        ),
        Category(
          id: 3,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/eq-test.png',
          nameEn: 'EQ Test',
          nameZh: '情商测试',
          nameKh: 'តេស្តអេគ្យូ (ភាពចេះដឹងអារម្មណ៍)',
        ),
        Category(
          id: 4,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/history.png',
          nameEn: 'History',
          nameZh: '历史',
          nameKh: 'ប្រវត្តិសាស្ត្រ',
        ),
        Category(
          id: 5,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/science.png',
          nameEn: 'Science',
          nameZh: '科学',
          nameKh: 'វិទ្យាសាស្ត្រ',
        ),
        Category(
          id: 6,
          iconUrl: 'https://quiz-api.camtech-dev.online/images/category/geography.png',
          nameEn: 'Geography',
          nameZh: '地理',
          nameKh: 'ភូមិសាស្ត្រ',
        ),
      ],
      banners: [
        BannerItem(id: 1, name: 'assets/images/banner.png'),
        BannerItem(id: 2, name: 'assets/images/banner.png'),
      ],
      promotions: [
        Promotion(id: 1, name: 'Featured Quiz'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                  : _homeData == null
                  ? _buildErrorSection()
                  : _buildContent(),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.quiz, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'QuizMaster',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _buildHeaderButton(Icons.language, _switchLanguage),
          const SizedBox(width: 8),
          _buildHeaderButton(Icons.refresh, _fetchHomeData),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 18),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildWelcomeCard(),
            const SizedBox(height: 32),
            _buildBannerSection(),
            const SizedBox(height: 40),
            _buildCategoriesSection(),
            const SizedBox(height: 40),
            _buildPromotionSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedText('Welcome back!', '欢迎回来！', 'សូមស្វាគមន៍!'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getLocalizedText(
                    'Ready for your next challenge?',
                    '准备好迎接下一个挑战了吗？',
                    'តើអ្នកត្រៀមខ្លួនសម្រាប់បញ្ហាប្រឈមបន្ទាប់ហើយឬនៅ?',
                  ),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.psychology, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSection() {
    final bannerImages = _homeData!.banners.isNotEmpty
        ? _homeData!.banners.map((b) => b.name ?? 'assets/images/banner.png').toList()
        : ['assets/images/banner.png'];

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerPageController,
            onPageChanged: (index) => setState(() => _currentBannerIndex = index),
            itemCount: bannerImages.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(bannerImages[index], fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(bannerImages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: _currentBannerIndex == index ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getLocalizedText('Categories', '分类', 'ប្រភេទ'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _homeData!.categories.length,
          itemBuilder: (context, index) => _buildCategoryCard(_homeData!.categories[index], index),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Category category, int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToQuiz(category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colors[index % colors.length].withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colors[index % colors.length].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: category.iconUrl.isNotEmpty
                    ? Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.network(
                    category.iconUrl,
                    fit: BoxFit.contain,
                    color: colors[index % colors.length],
                  ),
                )
                    : Icon(
                  Icons.quiz,
                  size: 24,
                  color: colors[index % colors.length],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.getName(_languageCode),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getLocalizedText('Challenge Yourself!', '挑战自己！', 'បង្កើនការប្រកួតប្រជែង!'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getLocalizedText(
                    'Test your knowledge and compete with others.',
                    '在多个类别中测试您的知识并与其他用户竞争。',
                    'ធ្វើតេស្តចំណេះដឹងរបស់អ្នកនិងប្រកួតជាមួយអ្នកផ្សេងទៀត។',
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.rocket_launch, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSection() {
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
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchHomeData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToQuiz(Category category) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
      ),
    );

    try {
      final token = await TokenService.getToken();
      final questions = await ApiService.getQuestionsByCategory(
        categoryId: category.id,
        token: token,
      );
      Navigator.of(context).pop();
      if (questions.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              questions: questions,
              categoryName: category.getName(_languageCode),
              categoryId: category.id,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No questions for ${category.getName(_languageCode)}')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  String _getLocalizedText(String en, String zh, String kh) {
    switch (_languageCode) {
      case 'en':
        return en;
      case 'zh':
        return zh;
      case 'kh':
        return kh;
      default:
        return en;
    }
  }
}