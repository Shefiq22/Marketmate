class SellerEarningsModel {
  final int pendingKobo;
  final int availableKobo;
  final int withdrawnKobo;
  final int totalKobo;

  const SellerEarningsModel({
    this.pendingKobo = 0,
    this.availableKobo = 0,
    this.withdrawnKobo = 0,
    this.totalKobo = 0,
  });

  factory SellerEarningsModel.fromJson(Map<String, dynamic> json) =>
      SellerEarningsModel(
        pendingKobo: json['pending'] as int? ?? 0,
        availableKobo: json['available'] as int? ?? 0,
        withdrawnKobo: json['withdrawn'] as int? ?? 0,
        totalKobo: json['total'] as int? ?? 0,
      );

  double get pendingNaira => pendingKobo / 100;
  double get availableNaira => availableKobo / 100;
  double get withdrawnNaira => withdrawnKobo / 100;
  double get totalNaira => totalKobo / 100;

  String get formattedTotal {
    final s = totalNaira.toStringAsFixed(2);
    return '\u20A6${_addCommas(s)}';
  }

  String get formattedAvailable {
    final s = availableNaira.toStringAsFixed(2);
    return '\u20A6${_addCommas(s)}';
  }

  String get formattedPending {
    final s = pendingNaira.toStringAsFixed(2);
    return '\u20A6${_addCommas(s)}';
  }

  String get formattedWithdrawn {
    final s = withdrawnNaira.toStringAsFixed(2);
    return '\u20A6${_addCommas(s)}';
  }

  static String _addCommas(String s) {
    final parts = s.split('.');
    final buf = StringBuffer();
    for (int i = 0; i < parts[0].length; i++) {
      if (i > 0 && (parts[0].length - i) % 3 == 0) buf.write(',');
      buf.write(parts[0][i]);
    }
    if (parts.length > 1) {
      buf.write('.');
      buf.write(parts[1]);
    }
    return buf.toString();
  }
}
