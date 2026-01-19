import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () => _searchController.clear(),
          ),
        ],
      ),
      body: _searchController.text.isEmpty
          ? _buildSearchSuggestions()
          : _buildSearchResults(),
    );
  }

  Widget _buildSearchSuggestions() {
    return ListView(
      children: [
        Container(
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.search, color: AppTheme.textSecondary),
                title: const Text('Search messages'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.person_search, color: AppTheme.textSecondary),
                title: const Text('Search contacts'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.photo, color: AppTheme.textSecondary),
                title: const Text('Search photos'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.link, color: AppTheme.textSecondary),
                title: const Text('Search links'),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent searches', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              SizedBox(height: 16),
              Text('No recent searches', style: TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text('No results found', style: TextStyle(color: AppTheme.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text(result.name[0]),
          ),
          title: Text(result.name),
          subtitle: Text(result.message),
          trailing: Text(result.time, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          onTap: () {},
        );
      },
    );
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _results = [];
      } else {
        _results = [
          SearchResult('John Doe', 'Hello there!', '10:30 AM'),
          SearchResult('Jane Smith', 'How are you?', '9:45 AM'),
          SearchResult('Group Chat', 'Meeting at 3 PM', 'Yesterday'),
        ].where((result) => 
          result.name.toLowerCase().contains(query.toLowerCase()) ||
          result.message.toLowerCase().contains(query.toLowerCase())
        ).toList();
      }
    });
  }
}

class SearchResult {
  final String name;
  final String message;
  final String time;

  SearchResult(this.name, this.message, this.time);
}