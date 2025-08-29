import 'package:flutter/material.dart';
import '../models/leaderboard.dart';
import '../services/api_service.dart';
import '../services/token_service.dart';
import '../utils/app_logger.dart';

class TopUsersScreen extends StatefulWidget {
  const TopUsersScreen({super.key});

  @override
  State<TopUsersScreen> createState() => _TopUsersScreenState();
}

class _TopUsersScreenState extends State<TopUsersScreen> {
  List<LeaderboardUser> _leaderboardUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token = await TokenService.getToken();
      final leaderboardData = await ApiService.getLeaderboard(token: token);

      final users = leaderboardData
          .map((userData) => LeaderboardUser.fromJson(userData))
          .toList();

      setState(() {
        _leaderboardUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error fetching leaderboard: ', e);
      setState(() {
        _errorMessage = 'Failed to load leaderboard. Please try again.';
        _isLoading = false;
        _leaderboardUsers = _createMockLeaderboardUsers();
      });
    }
  }

  List<LeaderboardUser> _createMockLeaderboardUsers() {
    return [
      LeaderboardUser(userId: 1, id: 1, totalScore: '2850', firstName: 'Sarah', lastName: 'Johnson'),
      LeaderboardUser(userId: 2, id: 2, totalScore: '2720', firstName: 'Mike', lastName: 'Chen'),
      LeaderboardUser(userId: 3, id: 3, totalScore: '2650', firstName: 'Emma', lastName: 'Wilson'),
      LeaderboardUser(userId: 4, id: 4, totalScore: '2580', firstName: 'Alex', lastName: 'Rodriguez'),
      LeaderboardUser(userId: 5, id: 5, totalScore: '2420', firstName: 'Lisa', lastName: 'Thompson'),
      LeaderboardUser(userId: 6, id: 6, totalScore: '2350', firstName: 'David', lastName: 'Kim'),
      LeaderboardUser(userId: 7, id: 7, totalScore: '2280', firstName: 'Rachel', lastName: 'Green'),
      LeaderboardUser(userId: 8, id: 8, totalScore: '2150', firstName: 'John', lastName: 'Doe'),
      LeaderboardUser(userId: 9, id: 9, totalScore: '2080', firstName: 'Maria', lastName: 'Garcia'),
      LeaderboardUser(userId: 10, id: 10, totalScore: '1950', firstName: 'Tom', lastName: 'Anderson'),
    ];
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
      case 2:
      case 3:
        return Icons.emoji_events;
      default:
        return Icons.person;
    }
  }

  String _getLeague(int score) {
    if (score >= 2500) return 'Diamond';
    if (score >= 2000) return 'Gold';
    if (score >= 1500) return 'Silver';
    return 'Bronze';
  }

  LinearGradient _getLeagueGradient(String league) {
    switch (league.toLowerCase()) {
      case 'diamond':
        return const LinearGradient(colors: [Colors.cyan, Colors.blueAccent]);
      case 'gold':
        return const LinearGradient(colors: [Colors.amber, Colors.orangeAccent]);
      case 'silver':
        return LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600]);
      case 'bronze':
        return const LinearGradient(colors: [Color(0xFFCD7F32), Color(0xFF8B4513)]);
      default:
        return LinearGradient(colors: [Colors.grey.shade400, Colors.grey.shade600]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Top Users',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Colors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchLeaderboard,
          ),
        ],
      ),
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 20, top: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).primaryColor, Colors.indigo],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.leaderboard, color: Colors.white, size: 60),
                const SizedBox(height: 8),
                const Text(
                  "Leaderboard",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "Top performers this month",
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, color: Colors.orange.shade200, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Using demo data',
                          style: TextStyle(color: Colors.orange.shade200, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // MAIN CONTENT
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_leaderboardUsers.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No leaderboard data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
            )
          else ...[
              if (_leaderboardUsers.length >= 3)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPodiumUser(_leaderboardUsers[1], 2),
                      _buildPodiumUser(_leaderboardUsers[0], 1),
                      _buildPodiumUser(_leaderboardUsers[2], 3),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _leaderboardUsers.length > 3 ? _leaderboardUsers.length - 3 : 0,
                  itemBuilder: (context, index) {
                    final user = _leaderboardUsers[index + 3];
                    final rank = index + 4;
                    return _buildUserCard(user, rank);
                  },
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildPodiumUser(LeaderboardUser user, int position) {
    final league = _getLeague(user.scoreAsInt);

    return Column(
      children: [
        CircleAvatar(
          radius: position == 1 ? 35 : 30,
          backgroundColor: _getRankColor(position).withOpacity(0.15),
          child: Icon(_getRankIcon(position), color: _getRankColor(position), size: position == 1 ? 40 : 32),
        ),
        const SizedBox(height: 10),
        CircleAvatar(
          radius: position == 1 ? 35 : 28,
          backgroundColor: Colors.grey.shade300,
          child: Icon(Icons.person, size: position == 1 ? 40 : 32, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            user.displayName,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: position == 1 ? 14 : 12, fontWeight: FontWeight.w600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          user.totalScore,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _getRankColor(position)),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            gradient: _getLeagueGradient(league),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            league,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(LeaderboardUser user, int rank) {
    final league = _getLeague(user.scoreAsInt);

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Rank Badge
            CircleAvatar(
              radius: 22,
              backgroundColor: _getRankColor(rank).withOpacity(0.15),
              child: Text(
                '#$rank',
                style: TextStyle(color: _getRankColor(rank), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 16),
            // Avatar
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, size: 32, color: Colors.grey.shade600),
            ),
            const SizedBox(width: 16),
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: _getLeagueGradient(league),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          league,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('ID: ${user.userId}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(user.totalScore,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text('total score',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
