import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String gender;
  final String email;
  final String photoUrl;
  final String displayName;
  final String bio;
  final String group;
  final String country;
  final String lvl;
  final String achievedLvl;
  final int points;
  final int historyGamesWon;
  final int historyGamesLost;
  final double winLooseRatio;

  User(
      {this.id,
      this.username,
        this.gender,
      this.email,
      this.photoUrl,
      this.displayName,
      this.bio,
      this.country,
      this.group,
      this.lvl,
      this.points,
      this.achievedLvl,
      this.winLooseRatio,
      this.historyGamesWon,
      this.historyGamesLost});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc.data()["id"],
      email: doc.data()["email"],
      username: doc.data()["username"],
      gender: doc.data()["gender"],
      photoUrl: doc.data()["photoUrl"],
      displayName: doc.data()["displayName"],
      bio: doc.data()["bio"],
      lvl: doc.data()["lvl"],
      points: doc.data()["points"],
      achievedLvl: doc.data()["achievedLvl"],
      winLooseRatio: doc.data()["winLooseRatio"],
      historyGamesWon: doc.data()["historyGamesWon"],
      historyGamesLost: doc.data()["historyGamesLost"],
    );
  }
}
