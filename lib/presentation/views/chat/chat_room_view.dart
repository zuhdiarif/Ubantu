import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ubantu/components/theme/app_colors.dart';
import 'package:ubantu/core/navigation/app_router.dart';
import 'package:ubantu/domain/models/chat_message_model.dart';
import 'package:ubantu/domain/models/chat_room_model.dart';
import 'package:ubantu/presentation/providers/chat_provider.dart';
import 'package:ubantu/presentation/providers/rating_provider.dart';
import 'package:ubantu/presentation/providers/sos_provider.dart';

class ChatRoomView extends StatefulWidget {
  final ChatRoomModel? initialRoom;

  const ChatRoomView({
    super.key,
    this.initialRoom,
  });

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> with WidgetsBindingObserver {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isOrderCardExpanded = true;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      if (widget.initialRoom != null) {
        chatProvider.setActiveRoom(widget.initialRoom!);
      } else if (chatProvider.activeRoom == null && chatProvider.rooms.isNotEmpty) {
        chatProvider.setActiveRoom(chatProvider.rooms.first);
      }
      _scrollToBottom();
    });

    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      final chatProvider = context.read<ChatProvider>();
      final active = chatProvider.activeRoom ?? widget.initialRoom;
      if (active != null) {
        chatProvider.loadMessages(active.id, isPolling: true);
        chatProvider.markAsRead(active.id);
      }
    });
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      if (_isOrderCardExpanded) {
        setState(() {
          _isOrderCardExpanded = false;
        });
      }
      _scrollToBottom();
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = View.of(context).viewInsets.bottom;
    if (bottomInset > 0) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          _scrollToBottom();
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _pollTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(ChatRoomModel room) async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    final success = await context.read<ChatProvider>().sendMessage(room.id, text);
    if (success) {
      _scrollToBottom();
    }
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h.$m';
  }

  void _showSosDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              'Darurat (SOS)',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah kamu berada dalam situasi bahaya? Tim keamanan kampus dan kontak darurat akan segera diberitahu dengan lokasimu saat ini.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SosProvider>().submitReport('Darurat Chat');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Peringatan SOS berhasil dikirim ke Satpam Kampus!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('KIRIM SOS'),
          ),
        ],
      ),
    );
  }

  void _showRatingSheet(BuildContext context, ChatRoomModel room) {
    int rating = 5;
    final reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3E7DE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Beri Penilaian Layanan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E281C),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bagaimana pengalamanmu bersama ${room.otherUserName}?',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5C6658),
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return IconButton(
                    iconSize: 36,
                    icon: Icon(
                      star <= rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFE5A93C),
                    ),
                    onPressed: () {
                      setSheetState(() {
                        rating = star;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reviewController,
                maxLines: 3,
                style: const TextStyle(
                  color: Color(0xFF1E281C),
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                ),
                decoration: InputDecoration(
                  hintText: 'Tulis ulasan opsional...',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8C9688),
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE3E7DE)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE3E7DE)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF86B049)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF283626),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: () async {
                  await context.read<RatingProvider>().submitRating(
                        room.orderId,
                        rating.toDouble(),
                        reviewController.text.trim(),
                      );
                  if (context.mounted) {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Terima kasih atas penilaian Anda!'),
                        backgroundColor: Color(0xFF86B049),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Kirim Penilaian',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final room = chatProvider.activeRoom ?? widget.initialRoom;

    if (room == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E281C),
              size: 20,
            ),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Chat',
            style: TextStyle(
              color: Color(0xFF1E281C),
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
        body: const Center(
          child: Text('Percakapan tidak ditemukan'),
        ),
      );
    }

    final isKeyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildTopBar(context, room),
            if (room.isActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _buildActiveOrderCard(context, room),
              ),
            if (!room.isActive) ...[
              _buildCompletedNoticeBanner(),
              const SizedBox(height: 8),
              _buildDateDivider('Hari ini'),
            ],
            Expanded(
              child: _buildMessagesList(chatProvider, room),
            ),
            if (!room.isActive && !isKeyboardOpen) ...[
              _buildOrderSummaryCard(context, room),
              _buildClosedNotice(),
            ],
            _buildBottomInput(context, room),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ChatRoomModel room) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 8,
        bottom: 12,
        left: 8,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8ECE3), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF1E281C),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRouter.chatInbox);
              }
            },
          ),
          CircleAvatar(
            radius: 20,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  room.otherUserName,
                  style: const TextStyle(
                    color: Color(0xFF1E281C),
                    fontSize: 16,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  room.otherUserFaculty ?? 'Mahasiswa Universitas Brawijaya',
                  style: const TextStyle(
                    color: Color(0xFF5C6658),
                    fontSize: 11,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.sos_rounded,
              color: Colors.red,
              size: 28,
            ),
            tooltip: 'Darurat SOS',
            onPressed: () => _showSosDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard(BuildContext context, ChatRoomModel room) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E7DE), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F3E2E).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isOrderCardExpanded = !_isOrderCardExpanded;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F2DF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGreen,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      room.serviceStatus,
                      style: const TextStyle(
                        color: Color(0xFF386624),
                        fontSize: 11,
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Order',
                        style: TextStyle(
                          color: Color(0xFF5C6658),
                          fontSize: 11,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        room.orderNumber,
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isOrderCardExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF5C6658),
                  ),
                ],
              ),
            ),
          ),
          if (_isOrderCardExpanded) ...[
            const Divider(height: 1, thickness: 1, color: Color(0xFFE8ECE3)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.serviceTitle,
                        style: const TextStyle(
                          color: Color(0xFF1E281C),
                          fontSize: 15,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        room.totalPrice ?? 'Barter',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 15,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.itemSummary,
                    style: const TextStyle(
                      color: Color(0xFF5C6658),
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.radio_button_checked, size: 16, color: AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PENJEMPUTAN',
                              style: TextStyle(
                                color: Color(0xFF8C9688),
                                fontSize: 10,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              room.pickupLocation,
                              style: const TextStyle(
                                color: Color(0xFF1E281C),
                                fontSize: 13,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: AppColors.accentOrange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TUJUAN',
                              style: TextStyle(
                                color: Color(0xFF8C9688),
                                fontSize: 10,
                                fontFamily: 'Plus Jakarta Sans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              room.destinationLocation,
                              style: const TextStyle(
                                color: Color(0xFF1E281C),
                                fontSize: 13,
                                fontFamily: 'Plus Jakarta Sans',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedNoticeBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2DF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primarySage.withValues(alpha: 0.6)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengiriman berhasil diselesaikan.',
                  style: TextStyle(
                    color: Color(0xFF1E281C),
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Chat akan tetap tersedia selama 24 jam setelah pesanan selesai.',
                  style: TextStyle(
                    color: Color(0xFF5C6658),
                    fontSize: 11,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDivider(String dateText) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8ECE3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateText,
          style: const TextStyle(
            color: Color(0xFF5C6658),
            fontSize: 11,
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider chatProvider, ChatRoomModel room) {
    if (chatProvider.isLoadingMessages) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    final messages = chatProvider.activeMessages;
    if (messages.isEmpty) {
      return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Center(
          child: Text(
            'Mulai kirim pesan ke ${room.otherUserName}',
            style: const TextStyle(
              color: Color(0xFF8C9688),
              fontSize: 13,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: ListView.builder(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final msg = messages[index];
          return _buildMessageBubble(msg);
        },
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg) {
    final timeStr = _formatTime(msg.createdAt);

    if (msg.isMe) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: const BoxConstraints(maxWidth: 290),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFF86B049),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                msg.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          constraints: const BoxConstraints(maxWidth: 290),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: const Color(0xFFE3E7DE)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E281C).withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                msg.message,
                style: const TextStyle(
                  color: Color(0xFF1E281C),
                  fontSize: 14,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  timeStr,
                  style: const TextStyle(
                    color: Color(0xFF8C9688),
                    fontSize: 11,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildOrderSummaryCard(BuildContext context, ChatRoomModel room) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E7DE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E281C).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2DF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF86B049)),
                ),
                child: Text(
                  room.serviceTitle.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF86B049),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Selesai Pada ',
                    style: TextStyle(
                      color: Color(0xFF5C6658),
                      fontSize: 11,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  Text(
                    _formatTime(room.closedAt ?? room.lastMessageTime),
                    style: const TextStyle(
                      color: Color(0xFF86B049),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            room.destinationLocation,
            style: const TextStyle(
              color: Color(0xFF1E281C),
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            room.itemSummary,
            style: const TextStyle(
              color: Color(0xFF5C6658),
              fontSize: 13,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Bayar',
                style: TextStyle(
                  color: Color(0xFF1E281C),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              Text(
                room.totalPrice ?? 'Rp 65.000',
                style: const TextStyle(
                  color: Color(0xFF86B049),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF283626),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              onPressed: () => _showRatingSheet(context, room),
              child: const Text(
                'Beri Penilaian',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE3E7DE), width: 1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Detail Pesanan #${room.orderNumber}'),
                    backgroundColor: const Color(0xFF283626),
                  ),
                );
              },
              child: const Text(
                'Lihat Detail Pesanan',
                style: TextStyle(
                  color: Color(0xFF283626),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosedNotice() {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 16, color: Color(0xFF8C9688)),
          SizedBox(width: 6),
          Text(
            'Chat ditutup secara otomatis dalam 23.59',
            style: TextStyle(
              color: Color(0xFF8C9688),
              fontSize: 12,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInput(BuildContext context, ChatRoomModel room) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE8ECE3), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF4),
              border: Border.all(color: const Color(0xFFE3E7DE), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, color: Color(0xFF5C6658), size: 22),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lampirkan foto atau dokumen'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE3E7DE)),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSendMessage(room),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1E281C),
                  fontFamily: 'Plus Jakarta Sans',
                ),
                decoration: const InputDecoration(
                  hintText: 'Tulis Pesan...',
                  hintStyle: TextStyle(
                    color: Color(0xFF8C9688),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF86B049),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _handleSendMessage(room),
            ),
          ),
        ],
      ),
    );
  }
}
