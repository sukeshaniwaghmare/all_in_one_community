import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import 'call_info_screen.dart';
import 'contact_selection_screen.dart';
import '../provider/call_provider.dart';
import '../../contacts/presentation/contacts_screen.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  int? _expandedIndex;
  final Set<int> _selectedCalls = {};
  bool get _isSelectionMode => _selectedCalls.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final callProvider = Provider.of<CallProvider>(context);
    final calls = callProvider.calls;

    return Scaffold(
      appBar: _isSelectionMode ? _buildSelectionAppBar() : null,
      body: Column(
        children: [
          if (!_isSelectionMode) _buildTopActions(),
          if (!_isSelectionMode) _buildCreateCallLink(),
          if (!_isSelectionMode) _buildRecentHeader(),
          _buildCallsList(calls, callProvider),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => setState(() => _selectedCalls.clear()),
      ),
      title: Text(
        '${_selectedCalls.length} selected',
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: _addToFavorites,
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.white),
          onPressed: _deleteSelectedCalls,
        ),
      ],
    );
  }

  Widget _buildCreateCallLink() {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Icon(Icons.link, color: Colors.white, size: 28),
      ),
      title: const Text(
        'Create call link',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: const Text('Share a link for your WhatsApp call'),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Call link created')),
        );
      },
    );
  }

  Widget _buildRecentHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Recent',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCallsList(List calls, CallProvider callProvider) {
    return Expanded(
      child: calls.isEmpty
          ? const Center(
              child: Text(
                'No call history',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: calls.length,
              itemBuilder: (context, index) {
                final call = calls[index];
                final isSelected = _selectedCalls.contains(index);
                
                return Column(
                  children: [
                    ListTile(
                      leading: _isSelectionMode
                          ? Checkbox(
                              value: isSelected,
                              onChanged: (value) => _toggleSelection(index),
                              activeColor: AppTheme.primaryColor,
                            )
                          : CircleAvatar(
                              backgroundColor: call.color,
                              child: Text(
                                call.avatar,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                      title: Text(
                        call.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: call.type == 'missed' ? Colors.red : null,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Icon(
                            _getCallIcon(call.type),
                            size: 16,
                            color: call.type == 'missed'
                                ? Colors.red
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(_formatTime(call.time)),
                        ],
                      ),
                      trailing: _isSelectionMode
                          ? null
                          : GestureDetector(
                              onTap: () {
                                callProvider.makeCall(call.name, call.phoneNumber, call.isVideo);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${call.isVideo ? 'Video' : 'Audio'} calling ${call.name}...')),
                                );
                              },
                              child: Icon(
                                call.isVideo ? Icons.videocam : Icons.call,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                      onTap: () {
                        if (_isSelectionMode) {
                          _toggleSelection(index);
                        } else {
                          setState(() {
                            _expandedIndex = _expandedIndex == index ? null : index;
                          });
                        }
                      },
                      onLongPress: () => _toggleSelection(index),
                    ),
                    if (_expandedIndex == index && !_isSelectionMode)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionIcon(
                              Icons.call,
                              'Audio',
                              AppTheme.primaryColor,
                              () => _makeCall(call.name, call.phoneNumber, false),
                            ),
                            _buildActionIcon(
                              Icons.videocam,
                              'Video',
                              AppTheme.primaryColor,
                              () => _makeCall(call.name, call.phoneNumber, true),
                            ),
                            _buildActionIcon(
                              Icons.message,
                              'Message',
                              AppTheme.primaryColor,
                              () => _sendMessage(call.name),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedCalls.contains(index)) {
        _selectedCalls.remove(index);
      } else {
        _selectedCalls.add(index);
      }
    });
  }

  void _addToFavorites() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedCalls.length} calls added to favorites')),
    );
    setState(() => _selectedCalls.clear());
  }

  void _deleteSelectedCalls() {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    final sortedIndices = _selectedCalls.toList()..sort((a, b) => b.compareTo(a));
    
    for (int index in sortedIndices) {
      callProvider.deleteCall(index);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_selectedCalls.length} calls deleted')),
    );
    setState(() => _selectedCalls.clear());
  }

  // 🔹 Top action buttons widget
  Widget _buildTopActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.call, 
            label: 'Call',
            onTap: () => _showCallDialog(),
          ),
          _ActionButton(
            icon: Icons.calendar_today, 
            label: 'Schedule',
            onTap: () => _showScheduleDialog(),
          ),
          _ActionButton(
            icon: Icons.dialpad, 
            label: 'Keypad',
            onTap: () => _showKeypad(),
          ),
          _ActionButton(
            icon: Icons.group, 
            label: 'Group',
            onTap: () => _showGroupCall(),
          ),
          _ActionButton(
            icon: Icons.favorite_border, 
            label: 'Favorites',
            onTap: () => _showFavorites(),
          ),
        ],
      ),
    );
  }

  void _makeDirectCall() {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.makeCall('Contact', '+1234567890', false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Making call...')),
    );
  }

  void _showCallDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ContactsScreen()),
    );
  }

  void _showScheduleDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ScheduleCallWidget(),
    );
  }

  void _showKeypad() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const KeypadWidget(),
    );
  }

  void _showGroupCall() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Call'),
        content: const Text('Start a group call with multiple contacts'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('Favorite Contacts', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  IconData _getCallIcon(String type) {
    switch (type) {
      case 'incoming':
        return Icons.call_received;
      case 'outgoing':
        return Icons.call_made;
      case 'missed':
        return Icons.call_received;
      default:
        return Icons.call;
    }
  }

  Widget _buildActionIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  void _makeCall(String name, String phoneNumber, bool isVideo) {
    setState(() => _expandedIndex = null);
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.makeCall(name, phoneNumber, isVideo);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${isVideo ? 'Video' : 'Audio'} calling $name...')),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  void _sendMessage(String name) {
    setState(() => _expandedIndex = null);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening chat with $name...')),
    );
  }
}

// 🔹 Action button UI
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.grey.shade200,
            child: Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// 🔹 WhatsApp-style Keypad Widget
class KeypadWidget extends StatefulWidget {
  const KeypadWidget({super.key});

  @override
  State<KeypadWidget> createState() => _KeypadWidgetState();
}

class _KeypadWidgetState extends State<KeypadWidget> {
  String _phoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Phone number display
          Container(
            height: 60,
            alignment: Alignment.center,
            child: Text(
              _phoneNumber.isEmpty ? 'Enter phone number' : _phoneNumber,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: _phoneNumber.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Keypad grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildKeypadButton('1', ''),
                _buildKeypadButton('2', 'ABC'),
                _buildKeypadButton('3', 'DEF'),
                _buildKeypadButton('4', 'GHI'),
                _buildKeypadButton('5', 'JKL'),
                _buildKeypadButton('6', 'MNO'),
                _buildKeypadButton('7', 'PQRS'),
                _buildKeypadButton('8', 'TUV'),
                _buildKeypadButton('9', 'WXYZ'),
                _buildKeypadButton('*', ''),
                _buildKeypadButton('0', '+'),
                _buildKeypadButton('#', ''),
              ],
            ),
          ),
          
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Backspace
              IconButton(
                onPressed: _phoneNumber.isNotEmpty ? _backspace : null,
                icon: const Icon(Icons.backspace, size: 28),
                color: _phoneNumber.isNotEmpty ? Colors.grey[700] : Colors.grey[400],
              ),
              
              // Call button
              Container(
                decoration: BoxDecoration(
                  color: _phoneNumber.isNotEmpty ? AppTheme.primaryColor : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _phoneNumber.isNotEmpty ? _makeCall : null,
                  icon: const Icon(Icons.call, color: Colors.white, size: 28),
                ),
              ),
              
              // Add contact
              IconButton(
                onPressed: _phoneNumber.isNotEmpty ? _addContact : null,
                icon: const Icon(Icons.person_add, size: 28),
                color: _phoneNumber.isNotEmpty ? Colors.grey[700] : Colors.grey[400],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String number, String letters) {
    return GestureDetector(
      onTap: () => _addNumber(number),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(50),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            if (letters.isNotEmpty)
              Text(
                letters,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addNumber(String number) {
    setState(() {
      _phoneNumber += number;
    });
  }

  void _backspace() {
    if (_phoneNumber.isNotEmpty) {
      setState(() {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      });
    }
  }

  void _makeCall() {
    final callProvider = Provider.of<CallProvider>(context, listen: false);
    callProvider.makeCall('Unknown', _phoneNumber, false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling $_phoneNumber...')),
    );
  }

  void _addContact() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add $_phoneNumber to contacts')),
    );
  }
}

// 🔹 WhatsApp-style Schedule Call Widget
class ScheduleCallWidget extends StatefulWidget {
  const ScheduleCallWidget({super.key});

  @override
  State<ScheduleCallWidget> createState() => _ScheduleCallWidgetState();
}

class _ScheduleCallWidgetState extends State<ScheduleCallWidget> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedContact = '';
  bool _isVideoCall = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Schedule Call',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Contact Selection
            ListTile(
              leading: const Icon(Icons.person, color: Colors.grey),
              title: Text(
                _selectedContact.isEmpty ? 'Select Contact' : _selectedContact,
                style: TextStyle(
                  color: _selectedContact.isEmpty ? Colors.grey : Colors.black,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectContact,
            ),
            const Divider(),
            
            // Date Selection
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.grey),
              title: const Text('Date'),
              subtitle: Text(_formatDate(_selectedDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectDate,
            ),
            const Divider(),
            
            // Time Selection
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.grey),
              title: const Text('Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectTime,
            ),
            const Divider(),
            
            // Call Type
            ListTile(
              leading: Icon(
                _isVideoCall ? Icons.videocam : Icons.call,
                color: Colors.grey,
              ),
              title: const Text('Call Type'),
              subtitle: Text(_isVideoCall ? 'Video Call' : 'Audio Call'),
              trailing: Switch(
                value: _isVideoCall,
                onChanged: (value) => setState(() => _isVideoCall = value),
                activeColor: AppTheme.primaryColor,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Schedule Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedContact.isNotEmpty ? _scheduleCall : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Schedule Call',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _selectContact() async {
    setState(() => _selectedContact = 'John Doe'); // Simulate contact selection
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _scheduleCall() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_isVideoCall ? 'Video' : 'Audio'} call scheduled with $_selectedContact on ${_formatDate(_selectedDate)} at ${_selectedTime.format(context)}',
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);
    
    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == tomorrow) {
      return 'Tomorrow';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
