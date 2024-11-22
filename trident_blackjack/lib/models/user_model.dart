class UserModel {
  final String uid;
  final String username;
  final int gamesPlayed;
  final int correctDecisions;
  final bool isPro;

  UserModel({
    required this.uid,
    required this.username,
    this.gamesPlayed = 0,
    this.correctDecisions = 0,
    this.isPro = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'gamesPlayed': gamesPlayed,
      'correctDecisions': correctDecisions,
      'isPro': isPro,
    };
  }
}
