import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl; // لتنسيق الوقت
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme.dart';
import 'chat_screen.dart';

class MyChatsScreen extends StatefulWidget {
  const MyChatsScreen({super.key});

  @override
  State<MyChatsScreen> createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).fetchChats();
    });
  }

  // 1. دالة لاستخراج الاسم
  String getSenderName(Map<String, dynamic> chat, String myId) {
    List users = chat['users'];
    var otherUser = users.firstWhere((u) => u['_id'] != myId, orElse: () => null);
    return otherUser != null ? otherUser['name'] : "مستخدم محذوف";
  }

  // 2. دالة لاستخراج وقت آخر رسالة
  String getLastMessageTime(Map<String, dynamic> chat) {
    if (chat['latestMessage'] == null) return '';
    try {
      DateTime date = DateTime.parse(chat['updatedAt']).toLocal();
      // إذا كان اليوم، اعرض الساعة، غير ذلك اعرض التاريخ
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        return intl.DateFormat('hh:mm a', 'en').format(date);
      } else {
        return intl.DateFormat('dd/MM', 'en').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final myId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'الرسائل',
          style: GoogleFonts.cairo(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.grey[600]),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: chatProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : chatProvider.myChats.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => chatProvider.fetchChats(),
                  color: AppTheme.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: chatProvider.myChats.length,
                    separatorBuilder: (ctx, i) => Divider(
                      color: Colors.grey[100],
                      indent: 80, // ليبدأ الخط بعد الصورة
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final chat = chatProvider.myChats[index];
                      final chatName = getSenderName(chat, myId!);
                      final time = getLastMessageTime(chat);
                      final lastMsgContent = chat['latestMessage'] != null
                          ? chat['latestMessage']['content']
                          : "ابدأ المحادثة الآن";

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatId: chat['_id'],
                                chatName: chatName,
                              ),
                            ),
                          ).then((_) => chatProvider.fetchChats()); // تحديث عند العودة
                        },
                        // صورة البروفايل (أو أول حرف من الاسم)
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: Text(
                            chatName.isNotEmpty ? chatName[0].toUpperCase() : '?',
                            style: GoogleFonts.cairo(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        // الاسم
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                chatName,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // الوقت
                            Text(
                              time,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        // نص الرسالة الأخيرة
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            lastMsgContent,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  // تصميم الحالة الفارغة (عندما لا توجد رسائل)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded, size: 60, color: AppTheme.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد رسائل بعد',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'تصفح الخدمات وتواصل مع الآخرين\nللبدء في تبادل المهارات',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}