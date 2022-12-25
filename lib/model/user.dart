class User {
  String? id;
  String? username;
  String? email;
  bool? notifications;
  List<dynamic>? features;
  int? tabcoins;
  int? tabcash;
  String? createdAt;
  String? updatedAt;

  User({
    this.id,
  });

  User.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        email = json['email'],
        notifications = json['notifications'],
        features = json['features'],
        tabcoins = json['tabcoins'],
        tabcash = json['tabcash'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'notifications': notifications,
        'features': features,
        'tabcoins': tabcoins,
        'tabcash': tabcash,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
