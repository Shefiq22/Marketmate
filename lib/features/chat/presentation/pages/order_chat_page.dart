import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/features/chat/models/order_message_model.dart';
import 'package:market_mate/features/chat/providers/chat_providers.dart';

class OrderChatPage extends ConsumerStatefulWidget {
  final String orderId;
  final String targetName;
  final String targetRole;

  const OrderChatPage({
    super.key,
    required this.orderId,
    required this.targetName,
    this.targetRole = 'customer',
  });

  @override
  ConsumerState<OrderChatPage> createState() => _OrderChatPageState();
}

class _OrderChatPageState extends ConsumerState<OrderChatPage> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _loaded = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_loaded) {
        _loaded = true;
        loadOrderMessages(ref, widget.orderId);
        markMessagesRead(ref, widget.orderId);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listening) {
      _listening = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        listenForNewMessages(ref, widget.orderId);
      });
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    sendTextMessage(ref, widget.orderId, text);
    _msgCtrl.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    await sendImageMessage(ref, widget.orderId, picked.path);
    _scrollToBottom();
  }

  void _showAttachmentSheet(BuildContext context, bool isDark) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachOption(
                  icon: Icons.image_rounded,
                  label: 'Gallery',
                  color: isDark ? const Color(0xFFCE93D8) : const Color(0xFF9C27B0),
                  isTablet: isTablet,
                  isDark: isDark,
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndSendImage(ImageSource.gallery);
                  },
                ),
                _attachOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: isDark ? const Color(0xFFEF5350) : const Color(0xFFE53935),
                  isTablet: isTablet,
                  isDark: isDark,
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndSendImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _attachOption({
    required IconData icon,
    required String label,
    required Color color,
    required bool isTablet,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: isTablet ? 64 : 56,
            height: isTablet ? 64 : 56,
            decoration: BoxDecoration(
              color: color.withAlpha((0.12 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: isTablet ? 30 : 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 13 : 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.06 : 16.0;
    final currentUser = ref.watch(currentUserProvider);
    final messages = ref.watch(messageListProvider(widget.orderId));
    final isLoading = ref.watch(messagesLoadingProvider(widget.orderId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : const Color(0xFFF5F5F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark, isTablet, hPad, currentUser),
            Expanded(
              child: isLoading && messages.isEmpty
                  ? _ShimmerLoading(isDark: isDark, isTablet: isTablet)
                  : messages.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
                          itemCount: messages.length,
                          itemBuilder: (_, i) => _buildMessageBubble(
                            messages[i], currentUser, isDark, isTablet, size,
                          ),
                        ),
            ),
            _buildInputBar(isDark, isTablet, hPad, padding),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, bool isTablet, double hPad, UserModel? currentUser) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.chevron_left_rounded,
              size: 28,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: isTablet ? 22 : 18,
            backgroundColor: isDark ? AppColors.cardDark : AppColors.gray1,
            child: Text(
              widget.targetName.isNotEmpty ? widget.targetName[0].toUpperCase() : '?',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.targetName,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 17 : 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                  ),
                ),
                Text(
                  'Order #${widget.orderId.substring(0, widget.orderId.length > 8 ? 8 : widget.orderId.length)}',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 12 : 11,
                    color: AppColors.gray2,
                  ),
                ),
              ],
            ),
          ),
          _RoleBadge(role: widget.targetRole, isDark: isDark, isTablet: isTablet),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48,
            color: AppColors.gray2,
          ),
          const SizedBox(height: 12),
          Text(
            'No messages yet',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Send a message to start the conversation',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: AppColors.gray2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    OrderMessage msg,
    UserModel? currentUser,
    bool isDark,
    bool isTablet,
    Size size,
  ) {
    final isMe = msg.senderId == currentUser?.userId;
    final showRole = !isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showRole && msg.senderRole != widget.targetRole)
            Padding(
              padding: EdgeInsets.only(
                left: isMe ? 0 : 8,
                right: isMe ? 8 : 0,
                bottom: 2,
              ),
              child: _RoleBadge(
                role: msg.senderRole,
                isDark: isDark,
                isTablet: isTablet,
                compact: true,
              ),
            ),
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (msg.isImage)
                  _buildImageBubble(msg, isMe, isDark, isTablet, size)
                else
                  _buildTextBubble(msg, isMe, isDark, isTablet, size),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4, right: 4),
                  child: Text(
                    formatTimestamp(msg.createdAt),
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 12 : 11,
                      color: AppColors.gray2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBubble(
    OrderMessage msg,
    bool isMe,
    bool isDark,
    bool isTablet,
    Size size,
  ) {
    return Container(
      constraints: BoxConstraints(maxWidth: size.width * 0.72),
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primary
            : (isDark ? AppColors.surfaceDark : AppColors.white),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        msg.content,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: isTablet ? 15 : 14,
          color: isMe ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.black),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildImageBubble(
    OrderMessage msg,
    bool isMe,
    bool isDark,
    bool isTablet,
    Size size,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: size.width * 0.72,
        maxHeight: isTablet ? 320 : 260,
      ),
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.transparent : Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMe ? 20 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 20),
        ),
        child: Image.network(
          msg.imageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              width: size.width * 0.72,
              height: isTablet ? 320 : 260,
              color: isDark ? AppColors.cardDark : AppColors.gray1,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            width: size.width * 0.72,
            height: isTablet ? 320 : 260,
            color: isDark ? AppColors.cardDark : AppColors.gray1,
            child: const Icon(Icons.broken_image_outlined, color: AppColors.gray2),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark, bool isTablet, double hPad, EdgeInsets padding) {
    return Container(
      padding: EdgeInsets.fromLTRB(hPad, 10, hPad, padding.bottom + 12),
      color: isDark ? AppColors.surfaceDark : AppColors.white,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.gray1,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 15 : 14,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Write message',
                        hintStyle: TextStyle(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showAttachmentSheet(context, isDark),
                    child: Icon(
                      Icons.attach_file_rounded,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                      size: isTablet ? 22 : 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _send,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 22 : 18,
                vertical: isTablet ? 14 : 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Send',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 15 : 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  final bool isDark;
  final bool isTablet;
  final bool compact;

  const _RoleBadge({
    required this.role,
    required this.isDark,
    required this.isTablet,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = switch (role.toLowerCase()) {
      'seller' => 'Seller',
      'rider' => 'Rider',
      'customer' || 'buyer' => 'Buyer',
      _ => role,
    };

    final Color bgColor = switch (role.toLowerCase()) {
      'seller' => AppColors.primarySurface,
      'rider' => AppColors.secondarySurface,
      _ => isDark ? AppColors.cardDark : AppColors.gray1,
    };

    final Color textColor = switch (role.toLowerCase()) {
      'seller' => AppColors.primaryDark,
      'rider' => AppColors.secondaryDark,
      _ => AppColors.gray2,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: isTablet ? (compact ? 11 : 12) : (compact ? 10 : 11),
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _ShimmerLoading extends StatefulWidget {
  final bool isDark;
  final bool isTablet;
  const _ShimmerLoading({required this.isDark, required this.isTablet});

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmerColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.06);
    final baseColor = widget.isDark
        ? AppColors.cardDark
        : AppColors.gray1;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final opacity = 0.3 + 0.7 * ((_controller.value * 2).clamp(0.0, 1.0));
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          itemCount: 6,
          itemBuilder: (_, i) {
            final isMe = i.isEven;
            final w = isMe ? 200.0 : 160.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    width: w,
                    height: 48,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(isMe ? 20 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 20),
                      ),
                    ),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
