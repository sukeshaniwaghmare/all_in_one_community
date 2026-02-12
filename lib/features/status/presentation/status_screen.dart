import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';
import '../../camera/presentation/camera_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, String>> _filteredStatuses = [];
  
  final List<Map<String, String>> _allStatuses = [
    {'name': 'User 1', 'time': '1 minutes ago'},
    {'name': 'User 2', 'time': '2 minutes ago'},
    {'name': 'User 3', 'time': '3 minutes ago'},
    {'name': 'User 4', 'time': '4 minutes ago'},
    {'name': 'User 5', 'time': '5 minutes ago'},
  ];

  @override
  void initState() {
    super.initState();
    _filteredStatuses = _allStatuses;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterStatuses(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredStatuses = _allStatuses;
      } else {
        _filteredStatuses = _allStatuses
            .where((status) => status['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: _isSearching ? '' : 'Status',
        titleWidget: _isSearching ? TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search status...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          onChanged: _filterStatuses,
          onSubmitted: (value) {
            _filterStatuses(value);
          },
        ) : null,
        leading: _isSearching ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _searchFocusNode.unfocus(); // Hide keyboard
            setState(() {
              _isSearching = false;
              _searchController.clear();
              _filteredStatuses = _allStatuses;
            });
          },
        ) : null,
        actions: _isSearching ? [] : [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
              // Request focus to show keyboard
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchFocusNode.requestFocus();
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'create_channel':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create channel')),
                  );
                  break;
                case 'status_privacy':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Status privacy')),
                  );
                  break;
                case 'starred':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Starred')),
                  );
                  break;
                case 'settings':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings')),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create_channel',
                child: Text('Create channel'),
              ),
              const PopupMenuItem(
                value: 'status_privacy',
                child: Text('Status privacy'),
              ),
              const PopupMenuItem(
                value: 'starred',
                child: Text('Starred'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildMyStatus(),
          const Divider(height: 8, thickness: 8, color: Color(0xFFF0F0F0)),
          _buildRecentUpdates(),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "text_status",
            mini: true,
            backgroundColor: Colors.grey[600],
            onPressed: () {},
            child: const Icon(Icons.edit, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "camera_status",
            backgroundColor: AppTheme.primaryColor,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => const CameraScreen()
              ));
            },
            child: const Icon(Icons.camera_alt, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMyStatus() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor,
                child: Text('M', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                Text('Tap to add status update', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentUpdates() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Recent updates', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ),
          if (_filteredStatuses.isEmpty && _isSearching)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No status found', style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ..._filteredStatuses.map((status) => _buildStatusTile(status['name']!, status['time']!)),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String name, String time) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryColor, width: 2),
        ),
        child: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[300],
          child: Text(name[0], style: const TextStyle(fontSize: 18)),
        ),
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(time, style: const TextStyle(color: AppTheme.textSecondary)),
    );
  }
}