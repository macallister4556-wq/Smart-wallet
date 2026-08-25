class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final int targetMonths;
  final DateTime createdAt;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetMonths,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get monthlyTarget => targetMonths > 0 ? targetAmount / targetMonths : 0.0;
  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);
  int get monthsRemaining {
    if (targetMonths <= 0) return 0;
    final elapsed = DateTime.now().difference(createdAt).inDays ~/ 30;
    return (targetMonths - elapsed).clamp(0, targetMonths);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'targetMonths': targetMonths,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
        id: json['id'],
        name: json['name'],
        targetAmount: (json['targetAmount'] as num).toDouble(),
        currentAmount: (json['currentAmount'] as num).toDouble(),
        targetMonths: json['targetMonths'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  SavingsGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? currentAmount,
    int? targetMonths,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetMonths: targetMonths ?? this.targetMonths,
      createdAt: createdAt,
    );
  }
}
