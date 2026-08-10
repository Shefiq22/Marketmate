class ReferralEntry {
  final String id;
  final String refereeName;
  final String status;
  final int rewardAmountKobo;
  final String? unlockedAt;
  final String createdAt;

  const ReferralEntry({
    required this.id,
    required this.refereeName,
    required this.status,
    required this.rewardAmountKobo,
    this.unlockedAt,
    required this.createdAt,
  });

  factory ReferralEntry.fromJson(Map<String, dynamic> json) => ReferralEntry(
        id: json['id'] ?? json['_id'] ?? '',
        refereeName: json['refereeName'] ?? '',
        status: json['status'] ?? 'pending',
        rewardAmountKobo: (json['rewardAmountKobo'] as num?)?.toInt() ?? 0,
        unlockedAt: json['unlockedAt'],
        createdAt: json['createdAt'] ?? '',
      );
}

class ReferralStats {
  final String referralCode;
  final int totalReferred;
  final int pendingCount;
  final int completedCount;
  final int totalEarnedKobo;
  final List<ReferralEntry> referrals;

  const ReferralStats({
    required this.referralCode,
    required this.totalReferred,
    required this.pendingCount,
    required this.completedCount,
    required this.totalEarnedKobo,
    required this.referrals,
  });

  double get totalEarnedNaira => totalEarnedKobo / 100;

  factory ReferralStats.fromJson(Map<String, dynamic> json) => ReferralStats(
        referralCode: json['referralCode'] ?? '',
        totalReferred: (json['totalReferred'] as num?)?.toInt() ?? 0,
        pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
        completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
        totalEarnedKobo: (json['totalEarnedKobo'] as num?)?.toInt() ?? 0,
        referrals: (json['referrals'] as List<dynamic>? ?? [])
            .map((e) => ReferralEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class WalletLedgerEntry {
  final String id;
  final String type;
  final int amountKobo;
  final String? referenceId;
  final String description;
  final String createdAt;

  const WalletLedgerEntry({
    required this.id,
    required this.type,
    required this.amountKobo,
    this.referenceId,
    required this.description,
    required this.createdAt,
  });

  factory WalletLedgerEntry.fromJson(Map<String, dynamic> json) => WalletLedgerEntry(
        id: json['_id'] ?? '',
        type: json['type'] ?? '',
        amountKobo: (json['amountKobo'] as num?)?.toInt() ?? 0,
        referenceId: json['referenceId'],
        description: json['description'] ?? '',
        createdAt: json['createdAt'] ?? '',
      );
}

class WalletBalance {
  final int balanceKobo;
  final double balanceNaira;
  final List<WalletLedgerEntry> ledger;

  const WalletBalance({
    required this.balanceKobo,
    required this.balanceNaira,
    required this.ledger,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
        balanceKobo: (json['balanceKobo'] as num?)?.toInt() ?? 0,
        balanceNaira: (json['balanceNaira'] as num?)?.toDouble() ?? 0.0,
        ledger: (json['ledger'] as List<dynamic>? ?? [])
            .map((e) => WalletLedgerEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
