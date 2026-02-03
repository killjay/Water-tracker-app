import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final UserPreferences preferences;
  final List<CustomCupSize> customCupSizes;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.preferences,
    this.customCupSizes = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      preferences: UserPreferences.fromMap(map['preferences'] ?? {}),
      customCupSizes: (map['customCupSizes'] as List<dynamic>?)
              ?.map((e) => CustomCupSize.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'preferences': preferences.toMap(),
      'customCupSizes': customCupSizes.map((e) => e.toMap()).toList(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    UserPreferences? preferences,
    List<CustomCupSize>? customCupSizes,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      preferences: preferences ?? this.preferences,
      customCupSizes: customCupSizes ?? this.customCupSizes,
    );
  }
}

class UserPreferences {
  final double goal; // Daily goal in ml
  final String unit; // 'ml', 'oz', 'cups'
  final bool reminderEnabled;
  final bool smartTuningEnabled;
  final int reminderIntervalMinutes; // Default reminder interval
  // Onboarding / profile fields
  final double? weightKg;
  final String? activityLevel; // 'low', 'medium', 'high'
  final int? wakeTimeMinutes; // minutes from midnight
  final int? sleepTimeMinutes; // minutes from midnight
  final bool hasCompletedOnboarding;

  UserPreferences({
    required this.goal,
    this.unit = 'ml',
    this.reminderEnabled = true,
    this.smartTuningEnabled = true,
    this.reminderIntervalMinutes = 60,
    this.weightKg,
    this.activityLevel,
    this.wakeTimeMinutes,
    this.sleepTimeMinutes,
    this.hasCompletedOnboarding = false,
  });

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      goal: (map['goal'] as num?)?.toDouble() ?? 2000.0,
      unit: map['unit'] ?? 'ml',
      reminderEnabled: map['reminderEnabled'] ?? true,
      smartTuningEnabled: map['smartTuningEnabled'] ?? true,
      reminderIntervalMinutes: map['reminderIntervalMinutes'] ?? 60,
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      activityLevel: map['activityLevel'],
      wakeTimeMinutes: map['wakeTimeMinutes'],
      sleepTimeMinutes: map['sleepTimeMinutes'],
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'goal': goal,
      'unit': unit,
      'reminderEnabled': reminderEnabled,
      'smartTuningEnabled': smartTuningEnabled,
      'reminderIntervalMinutes': reminderIntervalMinutes,
      'weightKg': weightKg,
      'activityLevel': activityLevel,
      'wakeTimeMinutes': wakeTimeMinutes,
      'sleepTimeMinutes': sleepTimeMinutes,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  UserPreferences copyWith({
    double? goal,
    String? unit,
    bool? reminderEnabled,
    bool? smartTuningEnabled,
    int? reminderIntervalMinutes,
    double? weightKg,
    String? activityLevel,
    int? wakeTimeMinutes,
    int? sleepTimeMinutes,
    bool? hasCompletedOnboarding,
  }) {
    return UserPreferences(
      goal: goal ?? this.goal,
      unit: unit ?? this.unit,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      smartTuningEnabled: smartTuningEnabled ?? this.smartTuningEnabled,
      reminderIntervalMinutes: reminderIntervalMinutes ?? this.reminderIntervalMinutes,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      wakeTimeMinutes: wakeTimeMinutes ?? this.wakeTimeMinutes,
      sleepTimeMinutes: sleepTimeMinutes ?? this.sleepTimeMinutes,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class CustomCupSize {
  final String name;
  final double amount; // in ml

  CustomCupSize({
    required this.name,
    required this.amount,
  });

  factory CustomCupSize.fromMap(Map<String, dynamic> map) {
    return CustomCupSize(
      name: map['name'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
    };
  }
}
