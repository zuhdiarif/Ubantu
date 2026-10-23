import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';

class InboxView extends StatefulWidget {
  const InboxView({super.key});

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadRooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    final hourStr = time.hour.toString().padLeft(2, '0');
    final minuteStr = time.minute.toString().padLeft(2, '0');

    if (difference.inDays == 0 && now.day == time.day) {
      return '$hourStr.$minuteStr';
    } else if (difference.inDays == 1 || (difference.inDays == 0 && now.day != time.day)) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
      return days[time.weekday - 1];
    } else {
      return '${time.day.toString().padLeft(2, '0')}/${time.month.toString().padLeft(2, '0')}/${time.year.toString().substring(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAFA),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFA8C686),
            ),
            child: const Center(
              child: Text(
                'Chat',
                style: TextStyle(
                  color: Color(0xFF92613A),
                  fontSize: 20,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  height: 1.40,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => chatProvider.loadRooms(),
              color: AppColors.primaryGreen,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF86B049),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Chat hanya tersedia untuk pesanan yang telah dikonfirmasi.',
                      style: TextStyle(
                        color: Color(0xFFEAECEA),
                        fontSize: 15,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFBFC3BE),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => chatProvider.searchRooms(val),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFBFC3BE),
                          size: 22,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18, color: Color(0xFFBFC3BE)),
                                onPressed: () {
                                  _searchController.clear();
                                  chatProvider.searchRooms('');
                                },
                              )
                            : null,
                        hintText: 'Cari Percakapan',
                        hintStyle: const TextStyle(
                          color: Color(0xFFBFC3BE),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (chatProvider.isLoadingRooms)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primaryGreen),
                      ),
                    )
                  else if (chatProvider.rooms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Belum ada percakapan'
                                  : 'Percakapan tidak ditemukan',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...chatProvider.rooms.map((room) => _buildRoomItem(context, room)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomItem(BuildContext context, ChatRoomModel room) {
    return InkWell(
      onTap: () {
        context.read<ChatProvider>().setActiveRoom(room);
        context.push(AppRouter.chatRoom, extra: room);
      },
      borderRadius: BorderRadius.circular(10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE2F1D8),
                  child: Text(
                    room.otherUserName.isNotEmpty ? room.otherUserName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Color(0xFF263225),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              room.otherUserName,
                              style: const TextStyle(
                                color: Color(0xFF202020),
                                fontSize: 16,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: room.isActive
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: room.isActive
                                    ? const Color(0xFF86B049)
                                    : const Color(0xFFBFC3BE),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              room.serviceTitle,
                              style: TextStyle(
                                color: room.isActive
                                    ? const Color(0xFF86B049)
                                    : const Color(0xFF848484),
                                fontSize: 10,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.done_all,
                            size: 14,
                            color: Color(0xFF86B049),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              room.lastMessage.isNotEmpty
                                  ? room.lastMessage
                                  : 'Mulai percakapan baru',
                              style: const TextStyle(
                                color: Color(0xFF848484),
                                fontSize: 14,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTimestamp(room.lastMessageTime),
                      style: const TextStyle(
                        color: Color(0xFF86B049),
                        fontSize: 12,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.33,
                      ),
                    ),
                    if (room.unreadCount > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF86B049),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${room.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFEBEBEB),
          ),
        ],
      ),
    );
  }
}
