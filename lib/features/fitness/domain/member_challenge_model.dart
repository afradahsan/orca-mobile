class MemberChallengeProgress {
  final String challengeId;
  final int completedWorkouts;
  final int weeklyTarget;
  final int streak;
  final int totalAura;
  final int auraEarnedToday;
  final DateTime? lastLoggedDate;

  MemberChallengeProgress({
    required this.challengeId,
    required this.completedWorkouts,
    required this.weeklyTarget,
    required this.streak,
    required this.totalAura,
    required this.auraEarnedToday,
    this.lastLoggedDate,
  });

  factory MemberChallengeProgress.fromJson(Map<String, dynamic> json) {
    return MemberChallengeProgress(
      challengeId: json["challengeId"],
      completedWorkouts: json["completedWorkouts"],
      weeklyTarget: json["weeklyTarget"],
      streak: json["streak"],
      totalAura: json["totalAura"],
      auraEarnedToday: json["auraEarnedToday"] ?? 0,
      lastLoggedDate: json["lastLoggedDate"] != null
          ? DateTime.parse(json["lastLoggedDate"])
          : null,
    );
  }
}
