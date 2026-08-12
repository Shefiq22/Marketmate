import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/referral_models.dart';
import '../../providers/referral_provider.dart';
import '../../theme/app_theme.dart';

class ReferralScreen extends ConsumerWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(referralStatsProvider);
    final walletAsync = ref.watch(walletBalanceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Referrals & Wallet'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(referralStatsProvider);
            ref.invalidate(walletBalanceProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                walletAsync.when(
                  data: (wallet) => _WalletCard(balanceNaira: wallet.balanceNaira),
                  loading: () => const _WalletCardLoading(),
                  error: (e, _) => _WalletCardError(message: '$e'),
                ),
                const SizedBox(height: 20),
                statsAsync.when(
                  data: (stats) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        icon: Icons.card_giftcard_outlined,
                        title: 'Your referral code',
                        subtitle: 'Share your code and earn when friends shop',
                      ),
                      const SizedBox(height: 12),
                      _ReferralCodeCard(code: stats.referralCode),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _StatTile(
                              icon: Icons.group_add_outlined,
                              value: '${stats.totalReferred}',
                              label: 'Referred',
                              color: AppColors.info,
                              bgColor: AppColors.infoBg,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.check_circle_outline,
                              value: '${stats.completedCount}',
                              label: 'Completed',
                              color: AppColors.primary,
                              bgColor: AppColors.primaryBg,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatTile(
                              icon: Icons.hourglass_top_rounded,
                              value: '${stats.pendingCount}',
                              label: 'Pending',
                              color: AppColors.orange,
                              bgColor: AppColors.orangeBg,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        icon: Icons.history_rounded,
                        title: 'Referral history',
                        subtitle: stats.referrals.isEmpty
                            ? 'People who join with your code will show up here'
                            : 'Friends who joined using your code',
                      ),
                      const SizedBox(height: 12),
                      if (stats.referrals.isEmpty)
                        const _EmptyReferrals()
                      else
                        ...stats.referrals.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _ReferralTile(referral: r),
                          ),
                        ),
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text('Could not load referral stats: $e'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final double balanceNaira;
  const _WalletCard({required this.balanceNaira});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Wallet balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '₦${balanceNaira.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Earnings from referrals & rewards',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletCardLoading extends StatelessWidget {
  const _WalletCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _WalletCardError extends StatelessWidget {
  final String message;
  const _WalletCardError({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.redBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Could not load wallet: $message',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkText : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primaryBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReferralCodeCard extends StatelessWidget {
  final String code;
  const _ReferralCodeCard({required this.code});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CODE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.grey500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  code,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: AppColors.primaryBg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Referral code copied')),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Copy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color bgColor;
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkText : AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}

class _ReferralTile extends StatelessWidget {
  final ReferralEntry referral;
  const _ReferralTile({required this.referral});

  String get _initials {
    final parts = referral.refereeName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completed = referral.status == 'completed';
    final statusColor = completed ? AppColors.primary : AppColors.orange;
    final statusBg = completed ? AppColors.primaryBg : AppColors.orangeBg;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: statusBg,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.refereeName.isEmpty ? 'New friend' : referral.refereeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  completed
                      ? '₦${(referral.rewardAmountKobo / 100).toStringAsFixed(0)} earned'
                      : 'Reward unlocks once they shop',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.grey500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  completed ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                  size: 13,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  referral.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReferrals extends StatelessWidget {
  const _EmptyReferrals();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No referrals yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Share your code with friends to start earning',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextSecondary : AppColors.grey500,
            ),
          ),
        ],
      ),
    );
  }
}
