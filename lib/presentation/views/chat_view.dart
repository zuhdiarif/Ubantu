import 'package:flutter/material.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/components/theme/app_typography.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
              child: Text(
                'Chat Diskusi',
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E281C),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildChatItem(
                    name: 'Ahmad Farel',
                    message: 'Halo, untuk lokasi kosnya di mana ya?',
                    time: '10:15',
                    unreadCount: 2,
                    avatarUrl: 'assets/images/img_avatar_farel.png',
                  ),
                  _buildChatItem(
                    name: 'Anisa Rahmawati',
                    message: 'Siap, saya bantu bawa 2 kardus barang.',
                    time: 'Yesterday',
                    unreadCount: 0,
                  ),
                  _buildChatItem(
                    name: 'Dinda Putri',
                    message: 'Terima kasih atas bantuannya kemarin!',
                    time: '20 Jul',
                    unreadCount: 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatItem({
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    String? avatarUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EBE4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE2F1D8),
            backgroundImage: avatarUrl != null ? AssetImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    name[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF283626),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E281C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: AppTypography.body2.copyWith(
                    color: const Color(0xFF5C6658),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: AppTypography.caption.copyWith(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF283626),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
