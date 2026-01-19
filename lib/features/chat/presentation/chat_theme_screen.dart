import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/apptopbar.dart';

class ChatThemeScreen extends StatefulWidget {
  final Map<String, dynamic>? currentTheme;
  
  const ChatThemeScreen({super.key, this.currentTheme});

  @override
  State<ChatThemeScreen> createState() => _ChatThemeScreenState();
}

class _ChatThemeScreenState extends State<ChatThemeScreen> {
  late String _selectedTheme;
  
  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme?['name'] ?? 'Default';
  }
  
  final List<Map<String, dynamic>> _themes = [
    {'name': 'Default', 'color': Colors.teal, 'background': Colors.grey[100]},
    {'name': 'Blue', 'color': Colors.blue, 'background': Colors.blue[50]},
    {'name': 'Pink', 'color': Colors.pink, 'background': Colors.pink[50]},
    {'name': 'Purple', 'color': Colors.purple, 'background': Colors.purple[50]},
    {'name': 'Green', 'color': Colors.green, 'background': Colors.green[50]},
    {'name': 'Orange', 'color': Colors.orange, 'background': Colors.orange[50]},
    {'name': 'Red', 'color': Colors.red, 'background': Colors.red[50]},
    {'name': 'Amber', 'color': Colors.amber, 'background': Colors.amber[50]},
    {'name': 'Cyan', 'color': Colors.cyan, 'background': Colors.cyan[50]},
    {'name': 'Indigo', 'color': Colors.indigo, 'background': Colors.indigo[50]},
    {'name': 'Lime', 'color': Colors.lime, 'background': Colors.lime[50]},
    {'name': 'Brown', 'color': Colors.brown, 'background': Colors.brown[50]},
    {'name': 'Deep Purple', 'color': Colors.deepPurple, 'background': Colors.deepPurple[50]},
    {'name': 'Deep Orange', 'color': Colors.deepOrange, 'background': Colors.deepOrange[50]},
    {'name': 'Blue Grey', 'color': Colors.blueGrey, 'background': Colors.blueGrey[50]},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppTopBar(
        title: 'Chat theme',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Choose a theme for this chat. The theme will be visible to both you and the other person.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              color: Colors.white,
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: _themes.length,
                itemBuilder: (context, index) {
                  final theme = _themes[index];
                  final isSelected = _selectedTheme == theme['name'];
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTheme = theme['name'];
                      });
                      Navigator.pop(context, theme);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? theme['color'] : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme['background'],
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme['color'],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Hello', style: TextStyle(color: Colors.white, fontSize: 12)),
                                    ),
                                  ),
                                  Positioned(
                                    left: 8,
                                    bottom: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Hi there!', style: TextStyle(fontSize: 12)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              theme['name'],
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? theme['color'] : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}