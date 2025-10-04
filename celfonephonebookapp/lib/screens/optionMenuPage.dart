import 'package:celfonephonebookapp/screens/earningDetailsPage.dart';
import 'package:celfonephonebookapp/screens/media_partner_signup.dart';
import 'package:flutter/material.dart';

class OptionMenuPage extends StatelessWidget {
  const OptionMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        "title": "Data Entry",
        "icon": Icons.edit_note,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MediaPartnerSignupPage(), // <- add your page here
            ),
          );
        },
      },
      {
        "title": "Earning Details",
        "icon": Icons.account_balance_wallet,
        "onTap": () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EarningDetailsPage(), // <- add your page here
            ),
          );
        },
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Option Menu"),
      ),
      body: ListView.separated(
        itemCount: menuItems.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return ListTile(
            leading: Icon(item["icon"], color: Colors.blue),
            title: Text(item["title"]),
            trailing: const Icon(Icons.chevron_right),
            onTap: item["onTap"],
          );
        },
      ),
    );
  }
}
