class DailyStatsModel {
  final String userId;
  final String date; // Format: "YYYY-MM-DD"
  final double totalAmount; // in ml
  final int entryCount;
  final bool goalAchieved;

  DailyStatsModel({
    required this.userId,
    required this.date,
    required this.totalAmount,
    required this.entryCount,
    this.goalAchieved = false,
  });

  factory DailyStatsModel.fromMap(Map<String, dynamic> map) {
    return DailyStatsModel(
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      entryCount: map['entryCount'] ?? 0,
      goalAchieved: map['goalAchieved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'date': date,
      'totalAmount': totalAmount,
      'entryCount': entryCount,
      'goalAchieved': goalAchieved,
    };
  }

  DailyStatsModel copyWith({
    String? userId,
    String? date,
    double? totalAmount,
    int? entryCount,
    bool? goalAchieved,
  }) {
    return DailyStatsModel(
      userId: userId ?? this.userId,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      entryCount: entryCount ?? this.entryCount,
      goalAchieved: goalAchieved ?? this.goalAchieved,
    );
  }
}
