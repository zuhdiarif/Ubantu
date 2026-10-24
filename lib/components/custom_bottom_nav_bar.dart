import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_typography.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool? hasUnreadChat;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasUnreadChat,
  });

  @override
  Widget build(BuildContext context) {
    ChatProvider? chatProvider;
    try {
      chatProvider = context.watch<ChatProvider>();
    } catch (_) {}
    final showRedDot = hasUnreadChat ?? (chatProvider?.hasUnreadMessages ?? false);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F0),
        border: Border(
          top: BorderSide(
            color: Color(0xFFE3E7DE),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Beranda', false),
              _buildNavItem(1, Icons.chat_bubble_rounded, 'Chat', showRedDot),
              _buildNavItem(2, Icons.article_rounded, 'Aktivitas', false),
              _buildNavItem(3, Icons.person_rounded, 'Profil', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool hasBadge) {
    final isSelected = currentIndex == index;
    const activeColor = Color(0xFF283626);
    const inactiveColor = Color(0xFF8A9786);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 24,
                ),
                if (hasBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF44336),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.overline.copyWith(
                color: isSelected ? activeColor : inactiveColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 11,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
