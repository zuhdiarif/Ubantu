import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/notification_model.dart';
import 'package:ubantu/presentation/providers/notification_provider.dart';

class NotificationView extends StatelessWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.filteredNotifications;
    final unreadCount = provider.unreadCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E281C),
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Riwayat Notifikasi',
          style: AppTypography.h4.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E281C),
          ),
        ),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: Text(
                'Tandai Dibaca',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(context, provider),
          if (unreadCount > 0)
            _buildUnreadBanner(context, unreadCount),
          Expanded(
            child: notifications.isEmpty
                ? _buildEmptyState(context, provider.selectedFilter)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return _buildNotificationCard(context, provider, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, NotificationProvider provider) {
    final filters = ['Semua', 'Pesanan', 'KTM', 'Pesan'];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: filters.map((filter) {
          final isSelected = provider.selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              selectedColor: const Color(0xFF283626),
              backgroundColor: const Color(0xFFF0F4EC),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF283626),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF283626)
                      : const Color(0xFFE2E7DE),
                ),
              ),
              showCheckmark: false,
              onSelected: (_) => provider.setFilter(filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUnreadBanner(BuildContext context, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: const Color(0xFFE8F2DF),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFF283626),
          ),
          const SizedBox(width: 8),
          Text(
            '$count notifikasi belum dibaca',
            style: AppTypography.caption.copyWith(
              color: const Color(0xFF283626),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationProvider provider,
    NotificationModel item,
  ) {
    final iconData = switch (item.type) {
      'order' => Icons.local_shipping_rounded,
      'ktm' => Icons.verified_user_rounded,
      'chat' => Icons.chat_bubble_rounded,
      _ => Icons.notifications_rounded,
    };

    final iconBgColor = switch (item.type) {
      'order' => const Color(0xFFE2F1D8),
      'ktm' => const Color(0xFFD6E4FF),
      'chat' => const Color(0xFFFFE8D6),
      _ => const Color(0xFFF0F4EC),
    };

    final iconColor = switch (item.type) {
      'order' => const Color(0xFF283626),
      'ktm' => const Color(0xFF1D39C4),
      'chat' => const Color(0xFFD46B08),
      _ => const Color(0xFF5C6658),
    };

    final badgeLabel = switch (item.type) {
      'order' => 'PESANAN',
      'ktm' => 'VERIFIKASI KTM',
      'chat' => 'PESAN CHAT',
      _ => 'INFO',
    };

    final timeAgo = _formatTimeAgo(item.createdAt);

    return InkWell(
      onTap: () {
        provider.markAsRead(item.id);
        _handleNotificationTap(context, item);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.isRead ? Colors.white : const Color(0xFFF9FBF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isRead
                ? const Color(0xFFE8EBE4)
                : const Color(0xFF86B049),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(iconData, color: iconColor, size: 22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: iconBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeAgo,
                        style: AppTypography.caption.copyWith(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if (!item.isRead) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF86B049),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.title,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E281C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: AppTypography.body2.copyWith(
                      color: const Color(0xFF5C6658),
                      height: 1.35,
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

  Widget _buildEmptyState(BuildContext context, String filter) {
    final message = switch (filter) {
      'Pesanan' => 'Belum ada notifikasi terkait status pesanan.',
      'KTM' => 'Belum ada notifikasi terkait verifikasi KTM.',
      'Pesan' => 'Belum ada notifikasi pesan chat baru.',
      _ => 'Semua riwayat perubahan status dan aktivitas akan muncul di sini.',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F4EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: Color(0xFF5C6658),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Notifikasi',
              style: AppTypography.h5.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E281C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body2.copyWith(
                color: const Color(0xFF5C6658),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel item) {
    if (item.type == 'chat') {
      context.push(AppRouter.chatInbox);
    } else if (item.type == 'ktm') {
      context.push(AppRouter.ktmVerification);
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) {
      return 'Baru saja';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m lalu';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}j lalu';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays}h lalu';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
