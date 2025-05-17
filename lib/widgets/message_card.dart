import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/message.dart';

// for showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () => _showBottomSheet(isMe),
        child: isMe ? _greenMessage() : _blueMessage());
  }

  // sender or another user message
  Widget _blueMessage() {
  if (widget.message.read.isEmpty) {
    APIs.updateMessageReadStatus(widget.message);
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Flexible(
        child: Container(
          padding: EdgeInsets.all(widget.message.type == Type.image
              ? mq.width * .03
              : mq.width * .045),
          margin: EdgeInsets.symmetric(
              horizontal: mq.width * .03, vertical: mq.height * .008),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFd0eaff), Color(0xFFe6f5ff)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              )
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: widget.message.type == Type.text
              ? Text(widget.message.msg,
                  style: const TextStyle(
                      fontSize: 16, color: Colors.black87, height: 1.4))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.message.msg,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 60),
                  ),
                ),
        ),
      ),
      Padding(
        padding: EdgeInsets.only(left: 6, right: mq.width * .03),
        child: Text(
          MyDateUtil.getFormattedTime(
              context: context, time: widget.message.sent),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    ],
  );
}


  // our or user message
 Widget _greenMessage() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Padding(
        padding: EdgeInsets.only(left: mq.width * .03),
        child: Row(
          children: [
            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded,
                  color: Colors.blueAccent, size: 18),
            const SizedBox(width: 4),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      Flexible(
        child: Container(
          padding: EdgeInsets.all(widget.message.type == Type.image
              ? mq.width * .03
              : mq.width * .045),
          margin: EdgeInsets.symmetric(
              horizontal: mq.width * .03, vertical: mq.height * .008),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFd4fcd1), Color(0xFFe6ffe2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(2, 2),
              )
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(25),
            ),
          ),
          child: widget.message.type == Type.text
              ? Text(widget.message.msg,
                  style: const TextStyle(
                      fontSize: 16, color: Colors.black87, height: 1.4))
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.message.msg,
                    placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.broken_image, size: 60),
                  ),
                ),
        ),
      ),
    ],
  );
}


  // bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: const BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(8))),
              ),

              widget.message.type == Type.text
                  ?
                  //copy option
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'copy_text'.tr(),
                      onTap: (ctx) async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          if (ctx.mounted) {
                            //for hiding bottom sheet
                            Navigator.pop(ctx);

                            Dialogs.showSnackbar(ctx, 'text_copied'.tr());
                          }
                        });
                      })
                  :
                  //save option
                  _OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: (ctx) async {
                        try {
                          log('Image Url: ${widget.message.msg}');
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'We Chat')
                              .then((success) {
                            if (ctx.mounted) {
                              //for hiding bottom sheet
                              Navigator.pop(ctx);
                              if (success != null && success) {
                                Dialogs.showSnackbar(
                                    ctx, 'Image Successfully Saved!');
                              }
                            }
                          });
                        } catch (e) {
                          log('ErrorWhileSavingImg: $e');
                        }
                      }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //edit option
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'edit_text'.tr(),
                    onTap: (ctx) {
                      if (ctx.mounted) {
                        _showMessageUpdateDialog(ctx);

                        //for hiding bottom sheet
                        // Navigator.pop(ctx);
                      }
                    }),

              //delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'delete_text'.tr(),
                    onTap: (ctx) async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        //for hiding bottom sheet
                        if (ctx.mounted) Navigator.pop(ctx);
                      });
                    }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //sent time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                      '${'sent_at'.tr()}: ${MyDateUtil.getMessageTime(time: widget.message.sent)}',

                  onTap: (_) {}),

              //read time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.message.read.isEmpty
                      ? 'read_at'.tr()
                      :'${'read_now'.tr()}: ${MyDateUtil.getMessageTime(time: widget.message.read)}' ,
                      
                  onTap: (_) {}),
            ],
          );
        });
  }

  //dialog for updating message content
  void _showMessageUpdateDialog(final BuildContext ctx) {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20))),

              //title
              title:  Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('edit_message'.tr(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(ctx);
                    },
                    child:  Text(
                      'cancel'.tr(),
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      APIs.updateMessage(widget.message, updatedMsg);
                      //hide alert dialog
                      Navigator.pop(ctx);

                      //for hiding bottom sheet
                      Navigator.pop(ctx);
                    },
                    child:  Text(
                      'update_message'.tr(),
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final Function(BuildContext) onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(context),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
