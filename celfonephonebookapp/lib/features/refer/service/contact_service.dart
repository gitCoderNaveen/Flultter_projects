import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  Future<Contact?> pickContact() async {
    if (!await FlutterContacts.requestPermission()) {
      return null;
    }

    return await FlutterContacts.openExternalPick();
  }
}