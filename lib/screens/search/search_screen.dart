// search_screen.dart - TrackMe User Search with Social Discovery
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'profile/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _api = ApiService();
  final _searchCtrl = TextEditingController();
  List<dynamic>? _results;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _search([String? query]) async {
    final q = query ?? _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await _api.searchUsers(q);
      setState(() {
        _results = res;
      });
    } catch (e) {
      setState(() { _error = 'Search failed'; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find People'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by username...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (v) {
                      if (v.length >= 2) _search(v);
                    },
                  ),
                ),
                if (_loading) const SizedBox(width: 8, child: CircularProgressIndicator()),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (_loading && (_results == null || _results!.isEmpty)) {
                  return const Center(child: Text('Searching...'));
                }
                if (_error.isNotEmpty) {
                  return Center(child: Text(_error));
                }
                if (_results == null) {
                  return const Center(child: Text('Search for users to see them here'));
                }
                if (_results!.isEmpty) {
                  return const Center(child: Text('No users found'));
                }
                return ListView.separated(
                  itemCount: _results!.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = _results![index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user['avatar_url'] != null ? null : AppTheme.primaryColor,
                        child: user['avatar_url'] != null
                            ? null
                            : const Icon(Icons.person, color: Colors.white),
                        backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
                      ),
                      title: Text(user['username'] ?? ''),
                      subtitle: Text((user['bio'] ?? 'No bio'), maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileScreen(username: user['username']),
                        ));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
