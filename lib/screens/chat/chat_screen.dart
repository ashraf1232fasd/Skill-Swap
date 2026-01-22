import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:intl/intl.dart' as intl; // مكتبة تنسيق الوقت

import '../../providers/chat_provider.dart';

import '../../providers/auth_provider.dart';

import '../../core/theme.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  final String chatName;

  const ChatScreen({super.key, required this.chatId, required this.chatName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  bool _isComposing =
      false; // لمتابعة حالة الكتابة (لتبديل الأيقونة بين مايكروفون وإرسال)

  @override
  void initState() {
    super.initState();

    // جلب الرسائل عند فتح الشاشة

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false)
          .fetchMessages(widget.chatId);
    });

    // مراقبة حقل النص لتغيير أيقونة الإرسال

    _controller.addListener(() {
      setState(() {
        _isComposing = _controller.text.trim().isNotEmpty;
      });
    });
  }

  // دالة للنزول لأسفل الشاشة عند وصول رسالة جديدة

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    final myId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    // إذا وصلت رسالة جديدة، انزل للأسفل

    if (chatProvider.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // لون خلفية واتساب الهادئ

      appBar: _buildAppBar(),

      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final msg = chatProvider.messages[index];

                      // تحديد هل أنا المرسل أم الطرف الآخر

                      final senderId = msg['sender'] is Map
                          ? msg['sender']['_id']
                          : msg['sender'];

                      final isMe = senderId == myId;

                      // --- معالجة الوقت الحقيقي ---

                      String time = '';

                      try {
                        if (msg['createdAt'] != null) {
                          // تحويل من توقيت السيرفر (UTC) إلى توقيت الهاتف المحلي

                          DateTime parsedDate =
                              DateTime.parse(msg['createdAt'].toString())
                                  .toLocal();

                          // التنسيق: 10:30 PM

                          time = intl.DateFormat('hh:mm a', 'en')
                              .format(parsedDate);
                        } else {
                          // وقت مؤقت للرسائل الجديدة جداً

                          time = intl.DateFormat('hh:mm a', 'en')
                              .format(DateTime.now());
                        }
                      } catch (e) {
                        time = '';
                      }

                      return _buildMessageBubble(msg['content'], isMe, time);
                    },
                  ),
          ),
          _buildMessageComposer(chatProvider),
        ],
      ),
    );
  }

  // --- 1. تصميم الشريط العلوي (AppBar) ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leadingWidth: 70,
      leading: InkWell(
        onTap: () => Navigator.pop(context),
        borderRadius: BorderRadius.circular(50),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_back, color: Colors.black87),
            const SizedBox(width: 5),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child:
                  const Icon(Icons.person, size: 20, color: AppTheme.primary),
            ),
          ],
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.chatName,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'متصل الآن', // يمكن ربطها بحالة السوكت لاحقاً

            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.green,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined, color: AppTheme.primary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined, color: AppTheme.primary),
          onPressed: () {},
        ),
      ],
    );
  }

  // --- 2. تصميم فقاعة الرسالة (Bubble) ---

  Widget _buildMessageBubble(String message, bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // أقصى عرض 75%
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding:
              const EdgeInsets.only(top: 10, left: 14, right: 14, bottom: 8),
          decoration: BoxDecoration(
            color: isMe ? AppTheme.primary : Colors.white,

            // زوايا مخصصة لتعطي شكل الفقاعة

            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: isMe ? Radius.zero : const Radius.circular(16),
              bottomRight: isMe ? const Radius.circular(16) : Radius.zero,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: isMe ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: isMe ? Colors.white70 : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (isMe)
                    const Icon(
                      Icons.done_all, // علامة الصحين

                      size: 14,

                      color: Colors.white70,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- 3. تصميم خانة الكتابة (Composer) ---

  Widget _buildMessageComposer(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.transparent,
      child: SafeArea(
        child: Row(
          children: [
            // حقل النص

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.emoji_emotions_outlined,
                          color: Colors.grey[600]),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: GoogleFonts.cairo(fontSize: 16),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة...',
                          hintStyle: GoogleFonts.cairo(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.attach_file, color: Colors.grey[600]),
                      onPressed: () {},
                    ),
                    if (!_isComposing)
                      IconButton(
                        icon: Icon(Icons.camera_alt_outlined,
                            color: Colors.grey[600]),
                        onPressed: () {},
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 6),

            // زر الإرسال / المايكروفون

            GestureDetector(
              onTap: () {
                if (_isComposing) {
                  chatProvider.sendMessage(_controller.text, widget.chatId);

                  _controller.clear();

                  setState(() => _isComposing = false);
                } else {
                  // هنا يمكن إضافة منطق تسجيل الصوت مستقبلاً
                }
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primary,
                child: Icon(
                  _isComposing ? Icons.send : Icons.mic,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
