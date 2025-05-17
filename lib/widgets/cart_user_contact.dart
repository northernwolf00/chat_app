import 'package:flutter/material.dart';
import 'package:we_chat/helper/LocalCache.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../screens/chat_screen.dart';
import 'dialogs/profile_dialog.dart';
import 'profile_image.dart';


class ChatUserCardContact extends StatefulWidget {
  final ChatUser user;
  final VoidCallback onUpdate;
  const ChatUserCardContact({super.key, required this.user, required this.onUpdate});

  @override
  State<ChatUserCardContact> createState() => _ChatUserCardContactState();
}

class _ChatUserCardContactState extends State<ChatUserCardContact> {
  Message? _message;

 

  @override
  void initState() {
    super.initState();
   
  }



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
       widget.onUpdate();
      
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
        elevation: 0.5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(user: widget.user),
              ),
            );
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

              if (list.isNotEmpty) _message = list[0];

              return ListTile(
                leading: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ProfileDialog(user: widget.user),
                    );
                  },
                  child: ProfileImage(
                    size: mq.height * .055,
                    url: widget.user.image,
                  ),
                ),
                title: Row(
                  children: [
                    
                    Expanded(
                      child: Text(
                        widget.user.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                   
                  ],
                ),
                subtitle: Text(
                  _message != null
                      ? _message!.type == Type.image
                          ? 'Image'
                          : _message!.msg
                      : widget.user.about,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_message != null)
                      _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 0, 230, 119),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                              ),
                            )
                          : Text(
                              MyDateUtil.getLastMessageTime(
                                context: context,
                                time: _message!.sent,
                              ),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


