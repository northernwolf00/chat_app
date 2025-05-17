// class ChatUser {
//   ChatUser({
//     required this.image,
//     required this.about,
//     required this.name,
//     required this.createdAt,
//     required this.isOnline,
//     required this.id,
//     required this.lastActive,
//     required this.email,
//     required this.pushToken,
//   });
//   late String image;
//   late String about;
//   late String name;
//   late String createdAt;
//   late bool isOnline;
//   late String id;
//   late String lastActive;
//   late String email;
//   late String pushToken;

//   ChatUser.fromJson(Map<String, dynamic> json) {
//     image = json['image'] ?? '';
//     about = json['about'] ?? '';
//     name = json['name'] ?? '';
//     createdAt = json['created_at'] ?? '';
//     isOnline = json['is_online'] ?? '';
//     id = json['id'] ?? '';
//     lastActive = json['last_active'] ?? '';
//     email = json['email'] ?? '';
//     pushToken = json['push_token'] ?? '';
//   }

//   Map<String, dynamic> toJson() {
//     final data = <String, dynamic>{};
//     data['image'] = image;
//     data['about'] = about;
//     data['name'] = name;
//     data['created_at'] = createdAt;
//     data['is_online'] = isOnline;
//     data['id'] = id;
//     data['last_active'] = lastActive;
//     data['email'] = email;
//     data['push_token'] = pushToken;
//     return data;
//   }
// }
class ChatUser {
  String image;
  String about;
  String name;
  String createdAt;
  bool isOnline;
  String id;
  String lastActive;
  String email;
  String pushToken;
  bool isPinned;
  bool isFavorite;

  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.isOnline,
    required this.id,
    required this.lastActive,
    required this.email,
    required this.pushToken,
    this.isPinned = false,
    this.isFavorite = false,
  });

  ChatUser.fromJson(Map<String, dynamic> json)
      : image = json['image'] ?? '',
        about = json['about'] ?? '',
        name = json['name'] ?? '',
        createdAt = json['created_at'] ?? '',
        isOnline = json['is_online'] ?? false,
        id = json['id'] ?? '',
        lastActive = json['last_active'] ?? '',
        email = json['email'] ?? '',
        pushToken = json['push_token'] ?? '',
        isPinned = json['isPinned'] ?? false,
        isFavorite = json['isFavorite'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'about': about,
      'name': name,
      'created_at': createdAt,
      'is_online': isOnline,
      'id': id,
      'last_active': lastActive,
      'email': email,
      'push_token': pushToken,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
    };
  }
}
