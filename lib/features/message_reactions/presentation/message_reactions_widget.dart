import 'package:flutter/material.dart';

class MessageReactionsWidget extends StatefulWidget {
  final String messageId;
  final Map<String, List<String>> reactions;
  final Function(String emoji) onReactionTap;
  
  const MessageReactionsWidget({
    super.key,
    required this.messageId,
    required this.reactions,
    required this.onReactionTap,
  });

  @override
  State<MessageReactionsWidget> createState() => _MessageReactionsWidgetState();
}

class _MessageReactionsWidgetState extends State<MessageReactionsWidget> {
  bool _showReactionPicker = false;
  
  final List<String> _quickReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.reactions.isNotEmpty) _buildExistingReactions(),
        if (_showReactionPicker) _buildReactionPicker(),
      ],
    );
  }

  Widget _buildExistingReactions() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: widget.reactions.entries.map((entry) {
          final emoji = entry.key;
          final users = entry.value;
          return GestureDetector(
            onTap: () => widget.onReactionTap(emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    users.length.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReactionPicker() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _quickReactions.map((emoji) {
          return GestureDetector(
            onTap: () {
              widget.onReactionTap(emoji);
              setState(() => _showReactionPicker = false);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          );
        }).toList(),
      ),
    );
  }

  void showReactionPicker() {
    setState(() => _showReactionPicker = true);
  }

  void hideReactionPicker() {
    setState(() => _showReactionPicker = false);
  }
}