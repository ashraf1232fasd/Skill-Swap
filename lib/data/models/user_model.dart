class User {
  final String id;
  final String name;
  final String email;
  final int timeBalance;
  final int frozenBalance;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.timeBalance,
    required this.frozenBalance,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      timeBalance: (json['timeBalance'] as num?)?.toInt() ?? 0,
      frozenBalance: (json['frozenBalance'] as num?)?.toInt() ?? 0,
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'name': name,
      'email': email,
      'timeBalance': timeBalance,
      'frozenBalance': frozenBalance,
      'token': token,
    };
  }


  User copyWith({
    String? id,
    String? name,
    String? email,
    int? timeBalance,
    int? frozenBalance,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      timeBalance: timeBalance ?? this.timeBalance,
      frozenBalance: frozenBalance ?? this.frozenBalance,
      token: token ?? this.token,
    );
  }
}
