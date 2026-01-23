import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class FindChannelsScreen extends StatefulWidget {
  const FindChannelsScreen({super.key});

  @override
  State<FindChannelsScreen> createState() => _FindChannelsScreenState();
}

class _FindChannelsScreenState extends State<FindChannelsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _channels = [
    {'name': 'Tech News', 'subscribers': '1.2M', 'description': 'Latest technology updates'},
    {'name': 'Sports Updates', 'subscribers': '850K', 'description': 'Live sports news and scores'},
    {'name': 'Weather Channel', 'subscribers': '500K', 'description': 'Daily weather forecasts'},
    {'name': 'News Today', 'subscribers': '2.1M', 'description': 'Breaking news and updates'},
    {'name': 'Entertainment', 'subscribers': '750K', 'description': 'Movies, music and celebrity news'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
        title: Text('Find Channels', style: TextStyle(color: AppTheme.primaryColor)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search channels...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _channels.length,
              itemBuilder: (context, index) {
                final channel = _channels[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(channel['name'][0]),
                  ),
                  title: Text(channel['name']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(channel['description']),
                      Text('${channel['subscribers']} subscribers', 
                           style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () => _followChannel(channel['name']),
                    child: const Text('Follow'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _followChannel(String channelName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Following $channelName')),
    );
  }
}