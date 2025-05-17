import 'dart:developer';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';
import '../widgets/profile_image.dart';
import 'view_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];

  List<String> _secretWords = [];

  @override
  void initState() {
    super.initState();
  
  }




  //for handling message text changes
  final _textController = TextEditingController();

 
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
      return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('secretWords')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final secretWordsDocs = snapshot.data!.docs;
          // _secretWords = secretWordsDocs
          //     .map((doc) => doc['word'].toString().toLowerCase())
          //     .toList();

           _secretWords.addAll(secretWordsDocs
              .map((doc) => doc['word'].toString().toLowerCase())
              .toList());
          // Print for debug
          for (var word in _secretWords) {
            print('Streamed secret word: $word');
          }
        }
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: PopScope(
      
        canPop: false,

        onPopInvokedWithResult: (_, __) {
          if (_showEmoji) {
            setState(() => _showEmoji = !_showEmoji);
            return;
          }

          // some delay before pop
          Future.delayed(const Duration(milliseconds: 300), () {
            try {
              if (Navigator.canPop(context)) Navigator.pop(context);
            } catch (e) {
              log('ErrorPop: $e');
            }
          });
        },

        //
        child: Scaffold(
          //app bar
          appBar: AppBar(
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),

          // backgroundColor: ,

          //body
          body: Stack(
            children: [
              Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/background.png"), // <-- your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                        stream: APIs.getAllMessages(widget.user),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            //if data is loading
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                              return const SizedBox();
              
                            //if some or all data is loaded then show it
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              _list = data
                                      ?.map((e) => Message.fromJson(e.data()))
                                      .toList() ??
                                  [];
              
                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    reverse: true,
                                    itemCount: _list.length,
                                    padding: EdgeInsets.only(top: mq.height * .01),
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return MessageCard(message: _list[index]);
                                    });
                              } else {
                                return const Center(
                                  child: Text('Salam! 👋',
                                      style: TextStyle(fontSize: 20)),
                                );
                              }
                          }
                        },
                      ),
                    ),
              
                    //progress indicator for showing uploading
                    if (_isUploading)
                      const Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                              padding:
                                  EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                              child: CircularProgressIndicator(strokeWidth: 2))),
              
                    //chat input filed
                    _chatInput(),
              
                    if (_showEmoji)
                      SizedBox(
                        height: mq.height * .35,
                        child: EmojiPicker(
                          textEditingController: _textController,
                          config: const Config(),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  });
  }

  // app bar widget
  Widget _appBar() {
    return SafeArea(
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ViewProfileScreen(user: widget.user)));
          },
          child: StreamBuilder(
              stream: APIs.getUserInfo(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                        [];

                return Row(
                  children: [
                    //back button
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.black54)),

                    //user profile picture
                    ProfileImage(
                      size: mq.height * .05,
                      url: list.isNotEmpty ? list[0].image : widget.user.image,
                    ),

                    //for adding some space
                    const SizedBox(width: 10),

                    //user name & last seen time
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //user name
                        Text(list.isNotEmpty ? list[0].name : widget.user.name,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500)),

                        //for adding some space
                        const SizedBox(height: 2),

                        //last seen time of user
                        Text(
                            list.isNotEmpty
                                ? list[0].isOnline
                                    ? 'Online'
                                    : MyDateUtil.getLastActiveTime(
                                        context: context,
                                        lastActive: list[0].lastActive)
                                : MyDateUtil.getLastActiveTime(
                                    context: context,
                                    lastActive: widget.user.lastActive),
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54)),
                      ],
                    )
                  ],
                );
              })),
    );
  }

  // bottom chat input field
  Widget _chatInput() {
  return Padding(
    padding: EdgeInsets.symmetric(
      vertical: mq.height * 0.01,
      horizontal: mq.width * 0.03,
    ),
    child: Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.emoji_emotions_outlined,
                      color: Colors.blueAccent),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    setState(() => _showEmoji = !_showEmoji);
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration:  InputDecoration(
                      hintText: "typing_message".tr(),
                      border: InputBorder.none,
                    ),
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    minLines: 1,
                    maxLines: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.green,
          shape: const CircleBorder(),
          elevation: 4,
          child: InkWell(
            onTap: () {
              if (_textController.text.trim().isNotEmpty) {
                final text = _textController.text.trim();

                final isSecret = _secretWords.any(
                    (word) => text.toLowerCase().contains(word));

                if (isSecret) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title:  Text('restricted_word_title'.tr()),
                      content:  Text(
                          'this_word_is_restricted'.tr()),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'))
                      ],
                    ),
                  );
                  return;
                }

                if (_list.isEmpty) {
                  APIs.sendFirstMessage(widget.user, text, Type.text);
                } else {
                  APIs.sendMessage(widget.user, text, Type.text);
                }

                _textController.clear();
              }
            },
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    ),
  );
}

}
