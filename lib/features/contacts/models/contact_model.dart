import 'package:flutter_contacts/flutter_contacts.dart' as fc;

class Contact {
  final String id;
  final String name;
  final String phoneNumber;
  final bool isAppUser;
  final String? profileImage;

  Contact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.isAppUser = false,
    this.profileImage,
  });

  factory Contact.fromFlutter(fc.Contact c) {
    return Contact(
      id: c.id,
      name: c.displayName.isEmpty ? 'Unknown' : c.displayName,
      phoneNumber: c.phones.isNotEmpty ? c.phones.first.number : '',
      isAppUser: false,
      profileImage: null,
    );
  }
}
