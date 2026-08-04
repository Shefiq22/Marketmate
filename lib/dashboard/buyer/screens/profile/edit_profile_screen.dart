import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/addresses_provider.dart';

// ─────────────── Edit Profile ───────────────
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  bool _populated = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _populated = user != null;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (!_populated && user != null) {
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phone;
      _populated = true;
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.text),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: _refreshProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24.0),
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryBg,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _initials(_nameCtrl.text),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 14,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      _nameCtrl.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    _buildField('Full name', _nameCtrl, Icons.person_outline),
                    const SizedBox(height: 18.0),
                    _buildField(
                      'Email',
                      _emailCtrl,
                      Icons.email_outlined,
                      keyboard: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 18.0),
                    _buildPhoneField(),
                    const SizedBox(height: 18.0),
                    _buildRoleField(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          child: GreenButton(
            label: AppLocalizations.of(context)!.profile_update,
            onTap: () async {
              await ref
                  .read(currentUserProvider.notifier)
                  .update(
                    name: _nameCtrl.text,
                    email: _emailCtrl.text,
                    phone: _phoneCtrl.text,
                  );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.profile_updated_success),
                  backgroundColor: AppColors.primary,
                ),
              );
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  String _initials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: ctrl,
          keyboardType: keyboard,
          style: TextStyle(color: isDark ? AppColors.darkText : AppColors.text),
          decoration: InputDecoration(
            suffixIcon: Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.darkTextSecondary : AppColors.grey400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('\u{1F1F3}\u{1F1EC}', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.grey500,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = ref.watch(currentUserProvider)?.role ?? 'customer';
    final roleLabel = switch (role) {
      'seller' => 'Seller / Farmer',
      'customer' => 'Buyer / Retailer',
      'rider' => 'Rider / Delivery',
      _ => role,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          enabled: false,
          controller: TextEditingController(text: roleLabel),
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : AppColors.text,
          ),
          decoration: InputDecoration(
            suffixIcon: Icon(
              Icons.person_rounded,
              size: 18,
              color: isDark ? AppColors.darkTextSecondary : AppColors.grey400,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _refreshProfile() async {
    final token = ApiClient().accessToken;
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profile_no_session)),
      );
      return;
    }
    final jwtUser = decodeUserFromJwt(token);
    if (jwtUser != null) {
      await ref
          .read(currentUserProvider.notifier)
          .update(
            name: jwtUser.name.isNotEmpty ? jwtUser.name : null,
            email: jwtUser.email.isNotEmpty ? jwtUser.email : null,
            phone: jwtUser.phone.isNotEmpty ? jwtUser.phone : null,
            role: jwtUser.role.isNotEmpty ? jwtUser.role : null,
            userId: jwtUser.userId.isNotEmpty ? jwtUser.userId : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profile_refreshed),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.profile_refresh_error)),
      );
    }
  }
}

// ─────────────── Address Book ───────────────
class AddressBookScreen extends ConsumerStatefulWidget {
  const AddressBookScreen({super.key});

  @override
  ConsumerState<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends ConsumerState<AddressBookScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressesProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Address Book',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.text),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_off_outlined, size: 48, color: isDark ? AppColors.darkTextSecondary : AppColors.grey400),
                      const SizedBox(height: 12),
                      Text(AppLocalizations.of(context)!.address_no_saved, style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(addressesProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      const SizedBox(height: 24.0),
                      ...addresses.map(
                        (addr) => _AddressCard(
                          address: addr,
                          onDelete: () {
                            ref.read(addressesProvider.notifier).remove(addr.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.address_deleted),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          onEdit: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditAddressScreen(address: addr),
                              ),
                            );
                            if (!mounted) return;
                            ref.read(addressesProvider.notifier).refresh();
                          },
                          onSetDefault: addr.isDefault
                            ? null
                            : () {
                                ref.read(addressesProvider.notifier).setDefault(addr.id);
                              },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          child: GreenButton(
            label: AppLocalizations.of(context)!.checkout_add_address,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddNewAddressScreen(),
                ),
              );
              if (!mounted) return;
              ref.read(addressesProvider.notifier).refresh();
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────── Address Card ───────────────
class _AddressCard extends StatelessWidget {
  final UserAddress address;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback? onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onDelete,
    required this.onEdit,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: size.height * 0.015),
      padding: EdgeInsets.all(size.width * 0.035),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  address.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
              ),
              Row(
                children: [
                  if (onSetDefault != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: onSetDefault,
                        child: Icon(
                          Icons.star_outline,
                          size: 18,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.grey500,
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: onEdit,
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.grey500,
                    ),
                  ),
                  SizedBox(width: size.width * 0.03),
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: size.height * 0.005),
          Text(
            address.address,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          Text(
            address.phone,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          if (address.isDefault)
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.01),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.02,
                  vertical: size.height * 0.004,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Default address',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────── Add New Address ───────────────
class AddNewAddressScreen extends ConsumerStatefulWidget {
  const AddNewAddressScreen({super.key});
  @override
  ConsumerState<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends ConsumerState<AddNewAddressScreen> {
  final _nameCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  String _state = 'Lagos';
  final _phoneCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _valid =>
    _nameCtrl.text.trim().isNotEmpty &&
    _addrCtrl.text.trim().isNotEmpty &&
    _phoneCtrl.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Add New Address',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.text),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),

                  Text(
                    'Label (e.g. Home, Office)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _nameCtrl,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.address_hint_home,
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.grey400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18.0),

                  Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _addrCtrl,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.address_hint_type,
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.grey400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18.0),

                  Text(
                    'State',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    initialValue: _state,
                    decoration: const InputDecoration(),
                    items: ['Lagos', 'Abuja', 'Kano', 'Rivers', 'Oyo', 'Ogun']
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.text,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _state = v!),
                  ),
                  const SizedBox(height: 18.0),

                  Text(
                    'Phone number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _phoneCtrl,
                    onChanged: (_) => setState(() {}),
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.address_hint_enter,
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.grey400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          child: GreenButton(
            label: _saving ? AppLocalizations.of(context)!.address_saving : AppLocalizations.of(context)!.address_add,
            onTap: _saving || !_valid
              ? null
              : () {
                  setState(() => _saving = true);
                  ref.read(addressesProvider.notifier).add({
                    'name': _nameCtrl.text.trim(),
                    'address': '${_addrCtrl.text.trim()}, ${_state}',
                    'phone': _phoneCtrl.text.trim(),
                    'isDefault': false,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.address_added),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Navigator.pop(context, true);
                },
          ),
        ),
      ),
    );
  }
}

// ─────────────── Edit Address ───────────────
class EditAddressScreen extends ConsumerStatefulWidget {
  final UserAddress address;
  const EditAddressScreen({super.key, required this.address});
  @override
  ConsumerState<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends ConsumerState<EditAddressScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _addrCtrl;
  late TextEditingController _phoneCtrl;
  String _state = 'Lagos';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.address.name);
    _addrCtrl = TextEditingController(text: widget.address.address);
    _phoneCtrl = TextEditingController(text: widget.address.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addrCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Edit Address',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.text),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),

                  Text(
                    'Label (e.g. Home, Office)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _nameCtrl,
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 18.0),

                  Text(
                    'Address',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _addrCtrl,
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 18.0),

                  Text(
                    'State',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField<String>(
                    initialValue: _state,
                    decoration: const InputDecoration(),
                    items: ['Lagos', 'Abuja', 'Kano', 'Rivers', 'Oyo']
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(
                              s,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.text,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _state = v!),
                  ),
                  const SizedBox(height: 18.0),

                  Text(
                    'Phone number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          child: GreenButton(
            label: _saving ? AppLocalizations.of(context)!.address_saving : AppLocalizations.of(context)!.address_save,
            onTap: _saving
              ? null
              : () {
                  setState(() => _saving = true);
                  final addressText = _addrCtrl.text.trim().contains(', $_state')
                    ? _addrCtrl.text.trim()
                    : '${_addrCtrl.text.trim()}, $_state';
                  ref.read(addressesProvider.notifier).edit(
                    widget.address.id,
                    {
                      'name': _nameCtrl.text.trim(),
                      'address': addressText,
                      'phone': _phoneCtrl.text.trim(),
                    },
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.address_saved),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                  Navigator.pop(context, true);
                },
          ),
        ),
      ),
    );
  }
}
