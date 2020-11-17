class User {
  bool isAdmin;
  String id;
  String username;
  String gender;
  String email;
  String photoUrl;
  String displayName;
  String bio;
  String group;
  String country;
  String lvl;
  String achievedLvl;
  String myStrength;
  String myFlaw;
  String myBlockDefense;
  String myExpectations;

  int myLikes;
  int points;
  int historyGamesWon;
  int historyGamesLost;
  double winLooseRatio;

  User(
      {this.isAdmin,
      this.id,
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
        this.myLikes,
      this.winLooseRatio,
      this.historyGamesWon,
      this.historyGamesLost,
      this.myStrength,
      this.myFlaw,
      this.myBlockDefense,
      this.myExpectations});
}
