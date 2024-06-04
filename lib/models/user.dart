class User {
  String homeCountry;
  bool? isAdmin;

  User({required this.homeCountry});

  Map<String, dynamic> toJson() {
    return {
      'homeCountry': homeCountry,
      'isAdmin': isAdmin ?? false,
    };
  }
}
