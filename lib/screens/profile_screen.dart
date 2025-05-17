import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:restart_app/restart_app.dart';
import 'package:we_chat/settings_singleton.dart';

import '../../api/apis.dart';
import '../../helper/dialogs.dart';
import '../../main.dart';
import '../../models/chat_user.dart';
import '../widgets/profile_image.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  int _tapCount = 0;

  void _handleAppBarTap() {
    setState(() {
      _tapCount++;
      if (_tapCount >= 10) {
        _tapCount = 0;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SecretScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: context.locale.languageCode == 'tr'
                  ? Image.asset(
                      'assets/images/turkman.png',
                      width: 24,
                      height: 24,
                    )
                  : context.locale.languageCode == 'ru'
                      ? Image.asset(
                          'assets/images/russian.png',
                          width: 24,
                          height: 24,
                        )
                      : Image.asset(
                          'assets/images/united-kingdom.png',
                          width: 24,
                          height: 24,
                        ),
              
              onSelected: (value) async {
                // await SettingsSingleton().changeLocale(value);
                final newLocale = Locale(value);
                await context
                    .setLocale(newLocale); // EasyLocalization handles this
                SettingsSingleton().changeLocale(value);
                // Restart.restartApp();
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'tr',
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/turkman.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text('Türkmen'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'ru',
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/russian.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text('Русский'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'en',
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/united-kingdom.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 10),
                      const Text('English'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.white],
              ),
            ),
          ),
          title: GestureDetector(
            onTap: _handleAppBarTap,
            child:  Text(
              'my_profile'.tr(),
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showLoading(context);
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                });
              });
            },
            icon: const Icon(Icons.logout),
            label:  Text('logout'.tr()),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .07),
            child: Column(
              children: [
                SizedBox(height: mq.height * .03),

                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: ClipOval(
                          child: ProfileImage(
                            size: mq.height * .18,
                            url: widget.user.image,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: mq.height * .02),

                Text(widget.user.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 15)),

                SizedBox(height: mq.height * .04),

                // Name Field
                buildTextField(
                  label: 'name'.tr(),
                  hintText: 'Myrat',
                  icon: Icons.person,
                  initialValue: widget.user.name,
                  onSaved: (val) => APIs.me.name = val ?? '',
                ),

                SizedBox(height: mq.height * .02),

                // About Field
                buildTextField(
                  label: 'about'.tr(),
                  hintText: 'Hakynda...',
                  icon: Icons.info_outline,
                  initialValue: widget.user.about,
                  onSaved: (val) => APIs.me.about = val ?? '',
                ),

                SizedBox(height: mq.height * .04),

                // Update Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Colors.blueAccent,
                    minimumSize: Size(mq.width * .5, mq.height * .06),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      APIs.updateUserInfo().then((value) {
                        Dialogs.showSnackbar(
                            context, 'profile_updated'.tr());
                      });
                    }
                  },
                  icon: const Icon(Icons.save),
                  label:  Text(
                    'update'.tr(),
                    style: TextStyle(fontSize: 16, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required String hintText,
    required IconData icon,
    required String? initialValue,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onSaved: onSaved,
      validator: (val) =>
          val != null && val.isNotEmpty ? null : 'required'.tr(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

class SecretScreen extends StatefulWidget {
  @override
  _SecretScreenState createState() => _SecretScreenState();
}

class _SecretScreenState extends State<SecretScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> _postSecret() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('secretWords').add({
        'word': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('secret_word_posted'.tr())),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteSecret(String docId) async {
    try {
      await _firestore.collection('secretWords').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('secret_word_deleted'.tr())),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('secret_words'.tr()),
        backgroundColor: Colors.lightBlue[400],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'enter_secret_word'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'type_secret_word'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _postSecret,
              icon: Icon(Icons.send),
              label: Text(_isLoading ? 'sending'.tr() : 'send'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue[400],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('secretWords').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('something_went_wrong'.tr());
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Text('no_secret_words'.tr());
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final word = doc['word'];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(word),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteSecret(doc.id),
                          ),
                        ),
                      );
                    },
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
