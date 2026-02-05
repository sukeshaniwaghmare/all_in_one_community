import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_theme.dart';

class MediaScreen extends StatelessWidget {
  final String chatName;

  const MediaScreen({super.key, required this.chatName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$chatName Media'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Media'),
                Tab(text: 'Docs'),
                Tab(text: 'Links'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMediaTab(),
                  _buildDocsTab(),
                  _buildLinksTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image, size: 40, color: Colors.grey),
        );
      },
    );
  }

  Widget _buildDocsTab() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.description, color: AppTheme.primaryColor),
          title: Text('Document ${index + 1}.pdf'),
          subtitle: const Text('2.5 MB • Yesterday'),
          trailing: const Icon(Icons.download),
        );
      },
    );
  }

  Widget _buildLinksTab() {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.link, color: AppTheme.primaryColor),
          title: const Text('https://example.com'),
          subtitle: const Text('Shared yesterday'),
          trailing: const Icon(Icons.open_in_new),
        );
      },
    );
  }
}