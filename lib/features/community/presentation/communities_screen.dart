import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final communities = [
      {
        'name': 'Tech Enthusiasts',
        'description': 'Latest tech news and discussions',
        'members': 1250,
        'image': 'T',
        'color': Colors.blue,
      },
      {
        'name': 'Flutter Developers',
        'description': 'Flutter development tips and tricks',
        'members': 890,
        'image': 'F',
        'color': Colors.cyan,
      },
      {
        'name': 'Design Community',
        'description': 'UI/UX design inspiration',
        'members': 567,
        'image': 'D',
        'color': Colors.purple,
      },
      {
        'name': 'Startup Hub',
        'description': 'Entrepreneurship and business ideas',
        'members': 2100,
        'image': 'S',
        'color': Colors.orange,
      },
    ];

    return Column(
      children: [
        // New Community Option
        ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          title: const Text(
            'New community',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Create new community')),
            );
          },
        ),
        const Divider(),
        
        // Communities List
        Expanded(
          child: ListView.builder(
            itemCount: communities.length,
            itemBuilder: (context, index) {
              final community = communities[index];
              return ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: community['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      community['image'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  community['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(community['description'] as String),
                    const SizedBox(height: 2),
                    Text(
                      '${community['members']} members',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Opened ${community['name']} community'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}