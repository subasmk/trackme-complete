// profile_screen.dart - TrackMe Public Profile with Badges
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({super.key, required this.username});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  Map<String, dynamic>? _profile;
  List<dynamic>? _badges;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await _api.getPublicProfile(widget.username);
      if (res['success']) {
        setState(() {
          _profile = res['data'];
          _badges = _profile?['badges'] ?? [];
        });
      } else {
        setState(() { _error = res['error'] ?? 'Profile not found'; });
      }
    } catch (e) {
      setState(() { _error = 'Network error'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_profile?['username'] ?? widget.username),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(fontSize: 16)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Avatar Header
                      Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.accentColor]),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 20)],
                        ),
                        child: const Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(_profile?['username'] ?? '', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(_profile?['bio'] ?? 'No bio yet', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 20),
                      // Stats Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('Goals', _profile?['stats']?['total_goals'] ?? 0),
                          _buildStatCard('Streaks', _profile?['stats']?['current_streaks'] ?? 0),
                          _buildStatCard('Badges', (_badges ?? []).length),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Badges Section
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('🏆 Badge Collection', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      ),
                      const SizedBox(height: 12),
                      if ((_badges ?? []).isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
                          child: const Text('No badges yet. Start tracking to earn your first badge!', style: TextStyle(color: Colors.grey)),
                        ),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: (_badges ?? []).map((badge) {
                          final isLegendary = badge['rarity'] == 'legendary';
                          final isEpic = badge['rarity'] == 'epic';
                          return Container(
                            width: 110,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isLegendary
                                  ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)])
                                  : isEpic
                                      ? const LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)])
                                      : const LinearGradient(colors: [Color(0xFF3498DB), Color(0xFF2980B9)]),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(badge['name'] ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                                const SizedBox(height: 4),
                                Text(badge['rarity']?.toUpperCase() ?? '', style: const TextStyle(fontSize: 10, color: Colors.white70)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}