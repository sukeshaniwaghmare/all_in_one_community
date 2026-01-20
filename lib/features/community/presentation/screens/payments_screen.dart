import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showPaymentHistory(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.account_balance_wallet, size: 80, color: Colors.green),
                const SizedBox(height: 16),
                const Text(
                  'Community Pay',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Send and receive money securely',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendMoney(context),
                        icon: const Icon(Icons.send),
                        label: const Text('Send Money'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _requestMoney(context),
                        icon: const Icon(Icons.request_page),
                        label: const Text('Request'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[600],
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: const Text('Add Payment Method'),
                  subtitle: const Text('Link your bank account or card'),
                  onTap: () => _addPaymentMethod(context),
                ),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Payment Security'),
                  subtitle: const Text('Manage your payment PIN'),
                  onTap: () => _paymentSecurity(context),
                ),
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help & Support'),
                  subtitle: const Text('Get help with payments'),
                  onTap: () => _showHelp(context),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.arrow_downward, color: Colors.white),
                  ),
                  title: const Text('Received from John'),
                  subtitle: const Text('Today, 2:30 PM'),
                  trailing: const Text('+₹500', style: TextStyle(color: Colors.green)),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.arrow_upward, color: Colors.white),
                  ),
                  title: const Text('Sent to Jane'),
                  subtitle: const Text('Yesterday, 4:15 PM'),
                  trailing: const Text('-₹200', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMoney(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send money feature opened')),
    );
  }

  void _requestMoney(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request money feature opened')),
    );
  }

  void _addPaymentMethod(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add payment method opened')),
    );
  }

  void _paymentSecurity(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment security settings opened')),
    );
  }

  void _showHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment help opened')),
    );
  }

  void _showPaymentHistory(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment history opened')),
    );
  }
}