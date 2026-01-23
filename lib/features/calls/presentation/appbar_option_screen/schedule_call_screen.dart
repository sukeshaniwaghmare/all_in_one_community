import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ScheduleCallScreen extends StatefulWidget {
  const ScheduleCallScreen({super.key});

  @override
  State<ScheduleCallScreen> createState() => _ScheduleCallScreenState();
}

class _ScheduleCallScreenState extends State<ScheduleCallScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedContact = '';
  bool _isVideoCall = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Schedule Call'),
        actions: [
          TextButton(
            onPressed: _selectedContact.isNotEmpty ? _scheduleCall : null,
            child: const Text('SCHEDULE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Select Contact'),
              subtitle: Text(_selectedContact.isEmpty ? 'Choose contact' : _selectedContact),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectContact,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectDate,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _selectTime,
            ),
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.videocam),
              title: const Text('Video Call'),
              subtitle: const Text('Schedule as video call'),
              value: _isVideoCall,
              onChanged: (value) => setState(() => _isVideoCall = value),
            ),
          ],
        ),
      ),
    );
  }

  void _selectContact() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Select Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  final contact = 'Contact ${index + 1}';
                  return ListTile(
                    title: Text(contact),
                    onTap: () {
                      setState(() => _selectedContact = contact);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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
      SnackBar(content: Text('${_isVideoCall ? 'Video call' : 'Call'} scheduled with $_selectedContact')),
    );
  }
}