enum SubscriptionStatus { free, pending, active, expired, cancelled }

class SubscriptionModel {
  final String? phoneNumber;
  final SubscriptionStatus status;
  final DateTime? subscribedAt;
  final DateTime? expiresAt;
  final String? planId;

  const SubscriptionModel({
    this.phoneNumber,
    this.status = SubscriptionStatus.free,
    this.subscribedAt,
    this.expiresAt,
    this.planId,
  });

  bool get isPro => status == SubscriptionStatus.active;

  SubscriptionModel copyWith({
    String? phoneNumber,
    SubscriptionStatus? status,
    DateTime? subscribedAt,
    DateTime? expiresAt,
    String? planId,
  }) {
    return SubscriptionModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      planId: planId ?? this.planId,
    );
  }

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'status': status.name,
        'subscribedAt': subscribedAt?.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'planId': planId,
      };

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      phoneNumber: json['phoneNumber'] as String?,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.free,
      ),
      subscribedAt: json['subscribedAt'] != null ? DateTime.tryParse(json['subscribedAt']) : null,
      expiresAt: json['expiresAt'] != null ? DateTime.tryParse(json['expiresAt']) : null,
      planId: json['planId'] as String?,
    );
  }
}