import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../helper/LocalCache.dart';

import '../models/chat_user.dart';
import '../widgets/chat_user_card.dart';
import '../widgets/profile_image.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // Handle app lifecycle
    SystemChannels.lifecycle.setMessageHandler((message) {
      log('Message: $message');
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        } else if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) {
          if (_isSearching) {
            setState(() => _isSearching = false);
            return;
          }
          Future.delayed(const Duration(milliseconds: 300), SystemNavigator.pop);
        },
        child: Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 1,
            leading: IconButton(
              tooltip: 'View Profile',
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: APIs.me)));
              },
              icon: const ProfileImage(size: 32),
            ),
            title: _isSearching
                ? TextField(
                    decoration:  InputDecoration(
                        border: InputBorder.none, hintText:  'app_title'.tr()
                        ),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (val) {
                      _searchList.clear();
                      val = val.toLowerCase();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val) ||
                            i.email.toLowerCase().contains(val)) {
                          _searchList.add(i);
                        }
                      }
                      setState(() {});
                    },
                  )
                : const Text('Oguz Chat',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
            actions: [
              IconButton(
                  tooltip: 'search'.tr(),
                  onPressed: () => setState(() => _isSearching = !_isSearching),
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : CupertinoIcons.search,
                      color: Colors.black)),
              IconButton(
                  tooltip: 'add_user'.tr(),
                  padding: const EdgeInsets.only(right: 8),
                  onPressed: _addChatUserDialog,
                  icon: const Icon(CupertinoIcons.person_add,
                      size: 25, color: Colors.black))
            ],
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUsers(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const Center(child: CircularProgressIndicator());
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];

                          final pinnedChats = _list
                              .where((chat) => LocalCache.isPinned(chat.id))
                              .toList();
                          final favoriteChats = _list
                              .where((chat) =>
                                  LocalCache.isFavorite(chat.id) &&
                                  !LocalCache.isPinned(chat.id))
                              .toList();
                          final otherChats = _list
                              .where((chat) =>
                                  !LocalCache.isFavorite(chat.id) &&
                                  !LocalCache.isPinned(chat.id))
                              .toList();

                          if (_list.isEmpty) {
                            return  Center(
                              child: Text('no_contacts'.tr(),
                                  style: TextStyle(fontSize: 20)),
                            );
                          }

                          List<Widget> buildSection(
                              String title, List<ChatUser> users) {
                            return users.isEmpty
                                ? []
                                : [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      child: Text(title,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey)),
                                    ),
                                    ...users
                                        .map((user) => ChatUserCard(
                                              user: user,
                                              onUpdate: () => setState(() {}),
                                            ))
                                        .toList()
                                  ];
                          }

                          final displayedUsers =
                              _isSearching ? _searchList : _list;

                          return ListView(
                            padding: const EdgeInsets.only(top: 8, bottom: 16),
                            physics: const BouncingScrollPhysics(),
                            children: _isSearching
                                ? displayedUsers
                                    .map((user) => ChatUserCard(
                                          user: user,
                                          onUpdate: () => setState(() {}),
                                        ))
                                    .toList()
                                : [
                                    ...buildSection("pined".tr(), pinnedChats),
                                    ...buildSection("favorite".tr(), favoriteChats),
                                    ...buildSection("", otherChats),
                                  ],
                          );
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15))),
        title:  Row(
          children: [
            Icon(Icons.person_add, color: Colors.blue, size: 28),
            SizedBox(width: 8),
            Text('add_user'.tr()),
          ],
        ),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration:  InputDecoration(
              hintText: 'enter_email'.tr(),
              prefixIcon: Icon(Icons.email, color: Colors.blue),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)))),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:  Text('cancel'.tr(),
                  style: TextStyle(color: Colors.blue, fontSize: 16))),
          TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (email.trim().isNotEmpty) {
                  final success = await APIs.addChatUser(email);
                  if (!success) {
                    Dialogs.showSnackbar(context, 'user_not_found'.tr());
                  }
                }
              },
              child:  Text('add'.tr(),
                  style: TextStyle(color: Colors.blue, fontSize: 16)))
        ],
      ),
    );
  }
}
