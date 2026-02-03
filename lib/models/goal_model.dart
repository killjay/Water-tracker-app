class GoalModel {
  final double dailyTarget; // in ml
  final String unit; // 'ml', 'oz', 'cups'
  final List<CustomCupSize> customCupSizes;

  GoalModel({
    required this.dailyTarget,
    this.unit = 'ml',
    this.customCupSizes = const [],
  });

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      dailyTarget: (map['dailyTarget'] as num?)?.toDouble() ?? 2000.0,
      unit: map['unit'] ?? 'ml',
      customCupSizes: (map['customCupSizes'] as List<dynamic>?)
              ?.map((e) => CustomCupSize.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dailyTarget': dailyTarget,
      'unit': unit,
      'customCupSizes': customCupSizes.map((e) => e.toMap()).toList(),
    };
  }

  GoalModel copyWith({
    double? dailyTarget,
    String? unit,
    List<CustomCupSize>? customCupSizes,
  }) {
    return GoalModel(
      dailyTarget: dailyTarget ?? this.dailyTarget,
      unit: unit ?? this.unit,
      customCupSizes: customCupSizes ?? this.customCupSizes,
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
