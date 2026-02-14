import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../data/datasources/community_datasource.dart';
import '../data/models/community_model.dart';
import 'community_detail_screen.dart';
import 'new_community_screen.dart';
import 'package:provider/provider.dart';
import '../provider/community_provider.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  final _dataSource = CommunityDataSource();
  List<CommunityModel> _communities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('CommunitiesScreen initState called');
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    print('Loading communities...');
    try {
      final communities = await _dataSource.fetchAllCommunities();
      print('Loaded ${communities.length} communities');
      setState(() {
        _communities = communities;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading communities: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    return Container(
      color: Colors.grey[50],
      child: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NewCommunityScreen()),
                );
                if (result == true) {
                  _loadCommunities();
                }
              },
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.groups, color: Colors.grey[600], size: 28),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('New community', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        SizedBox(height: 2),
                        Text('Bring together a neighbourhood, school, and more', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_communities.isEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(32),
              child: const Center(child: Text('No communities yet', style: TextStyle(color: Colors.grey))),
            )
          else
            Container(
              color: Colors.white,
              child: Column(
                children: List.generate(_communities.length, (index) {
                  final community = _communities[index];
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(community.icon ?? community.name[0].toUpperCase(), style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        title: Text(community.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        subtitle: Text('${community.memberCount} members', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        trailing: Consumer<CommunityProvider>(
                          builder: (context, provider, _) => IconButton(
                            icon: Icon(
                              provider.isFavorite(community.id) ? Icons.star : Icons.star_border,
                              color: provider.isFavorite(community.id) ? Colors.amber : Colors.grey,
                            ),
                            onPressed: () async {
                              await provider.toggleFavorite(community.id);
                            },
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityDetailScreen(community: community)));
                        },
                      ),
                      if (index < _communities.length - 1) const Divider(height: 1, indent: 78),
                    ],
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
