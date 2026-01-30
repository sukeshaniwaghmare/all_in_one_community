import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as fc;

class TestContactsPage extends StatefulWidget {
  const TestContactsPage({super.key});

  @override
  State<TestContactsPage> createState() => _TestContactsPageState();
}

class _TestContactsPageState extends State<TestContactsPage> {
  List<fc.Contact> contacts = [];
  bool isLoading = false;
  String status = 'Ready to load contacts';

  Future<void> testLoadContacts() async {
    setState(() {
      isLoading = true;
      status = 'Requesting permission...';
    });

    try {
      // Request permission
      if (!await fc.FlutterContacts.requestPermission()) {
        setState(() {
          status = 'Permission denied';
          isLoading = false;
        });
        return;
      }

      setState(() {
        status = 'Loading contacts...';
      });

      // Load contacts
      final loadedContacts = await fc.FlutterContacts.getContacts(
        withProperties: true,
      );

      setState(() {
        contacts = loadedContacts;
        status = 'Loaded ${contacts.length} contacts successfully!';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        status = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Contacts'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              status,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : testLoadContacts,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Load Contacts'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    title: Text(contact.displayName),
                    subtitle: Text(
                      contact.phones.isNotEmpty
                          ? contact.phones.first.number
                          : 'No phone number',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}