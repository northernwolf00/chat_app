import 'package:easy_localization/easy_localization.dart';
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


class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  final VoidCallback onUpdate;
  const ChatUserCard({super.key, required this.user, required this.onUpdate});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  late bool _isPinned;
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isPinned = LocalCache.isPinned(widget.user.id);
    _isFavorite = LocalCache.isFavorite(widget.user.id);
  }

  void _togglePin() async {
    _isPinned = !_isPinned;
    await LocalCache.setPinned(widget.user.id, _isPinned);
    widget.onUpdate();
  }

  void _toggleFavorite() async {
    _isFavorite = !_isFavorite;
    await LocalCache.setFavorite(widget.user.id, _isFavorite);
    widget.onUpdate();
  }




  void _showPopupMenu(Offset offset) async {
    final selected = await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy, offset.dx + 1, offset.dy + 1),
      items: [
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(
                _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(_isPinned ? 'unpin'.tr() : 'pinned'.tr()),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'favorite',
          child: Row(
            children: [
              Icon(
                _isFavorite ? Icons.star : Icons.star_border,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(_isFavorite ? 'unfavorite'.tr() : 'favorite'.tr()),
            ],
          ),
        ),
      ],
    );

    if (selected == 'pin') {
      _togglePin();
    } else if (selected == 'favorite') {
      _toggleFavorite();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        _showPopupMenu(details.globalPosition);
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
                    if (_isFavorite)
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                    if (_isPinned)
                      const Icon(Icons.push_pin, color: Colors.grey, size: 16),
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


