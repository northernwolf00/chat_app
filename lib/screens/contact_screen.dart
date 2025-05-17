import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:we_chat/helper/dialogs.dart';
import 'package:we_chat/widgets/cart_user_contact.dart';

import '../api/apis.dart';
import '../models/chat_user.dart';


class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('contacts'.tr(),
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder(
        stream: APIs.getAllUsersForContacts(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              final users =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              if (users.isEmpty) {
                return Center(
                  child:
                      Text('no_contacts'.tr(), style: TextStyle(fontSize: 18)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: users.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () async {
                    // final added = await APIs.addChatUser(users[index].email);
                  },
                  child: ChatUserCardContact(
                      user: users[index],
                      onUpdate: () => _addChatUserDialog(users[index].email)),
                ),
              );
          }
        },
      ),
    );
  }

  void _addChatUserDialog(String email) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        title: Row(
          children: [
            Icon(Icons.person_add, color: Colors.blue, size: 28),
            SizedBox(width: 8),
            Text('add_user'.tr(),
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        content: Text(
          '${'do_you_want_to_add'.tr()} $email ${'to_your_contacts'.tr()}',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text('cancel'.tr(),
                style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await APIs.addChatUser(email);
              if (!success) {
                Dialogs.showSnackbar(context, 'user_not_found'.tr());
              }
            },
            child:  Text('add'.tr(),
                style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
