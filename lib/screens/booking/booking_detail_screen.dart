import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:intl/date_symbol_data_local.dart';
import '../../core/theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../wallet/store_screen.dart';
import '../../providers/chat_provider.dart'; // <--- (1) إضافة استيراد ChatProvider
import '../chat/chat_screen.dart'; // <--- (2) إضافة استيراد شاشة الشات

class BookingScreen extends StatefulWidget {
  final Map<String, dynamic> service;

  const BookingScreen({super.key, required this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _isLocaleInitialized = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ar', null).then((_) {
      if (mounted) {
        setState(() {
          _isLocaleInitialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    DateTime serviceDate;
    try {
      serviceDate = DateTime.parse(widget.service['datetime'].toString());
    } catch (e) {
      serviceDate = DateTime.now();
    }

    final isRequest = widget.service['type'] == 'request';
    final phone = widget.service['phone'] ?? '';
    final countryCode = widget.service['countryCode'] ?? '';
    final fullPhone = '$countryCode $phone';
    final providerName = widget.service['provider']?['name'] ?? widget.service['user']?['name'] ?? 'مستخدم';
    final price = widget.service['price'] ?? 0;

    final actionColor = isRequest ? Colors.green : AppTheme.primary;
    final actionIcon = isRequest ? Icons.check_circle_outline : Icons.shopping_cart_checkout;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          isRequest ? 'تلبية الطلب' : 'تأكيد الحجز',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 1. بطاقة التفاصيل الأساسية
            _buildMainInfoCard(
              title: widget.service['title'] ?? 'بدون عنوان',
              category: widget.service['category'] ?? 'عام',
              providerName: providerName,
              price: price,
              isRequest: isRequest,
            ),

            const SizedBox(height: 16),

            // 2. بطاقة الموعد
            _buildDateCard(serviceDate),

            const SizedBox(height: 16),

            // 3. الوصف
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "تفاصيل الخدمة",
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.service['description'] ?? 'لا يوجد وصف',
                    style: GoogleFonts.cairo(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // 4. رقم الهاتف
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildContactCard(fullPhone),
            ],

            const SizedBox(height: 16),

            // --- (3) إضافة زر المراسلة الجديد ---
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _handleChatAction(context),
                icon: const Icon(Icons.chat, color: AppTheme.primary),
                label: Text(
                  'مراسلة الناشر',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppTheme.primary),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 5. التنبيه المالي
            _buildFinancialAlert(isRequest, price),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        color: const Color(0xFFF8F9FD),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: bookingProvider.isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
              : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => _handleBookingAction(context, bookingProvider, serviceDate, isRequest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      shadowColor: actionColor.withOpacity(0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(actionIcon, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          isRequest ? 'موافق، سأقوم بالتدريس' : 'تأكيد الحجز ($price دقيقة)',
                          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // --- Widgets ---

  Widget _buildMainInfoCard({
    required String title,
    required String category,
    required String providerName,
    required int price,
    required bool isRequest,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isRequest ? Colors.orange : AppTheme.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isRequest ? 'طالب' : 'معلم',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isRequest ? Colors.orange : AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[100],
                child: const Icon(Icons.person, color: Colors.grey, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الناشر',
                    style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey[500]),
                  ),
                  Text(
                    providerName,
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'المدة/السعر',
                    style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey[500]),
                  ),
                  Text(
                    '$price دقيقة',
                    style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(DateTime date) {
    final isReady = _isLocaleInitialized;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'موعد الجلسة',
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              ),
              Text(
                isReady
                    ? DateFormat('EEEE, d MMMM', 'ar').format(date)
                    : DateFormat('EEEE, d MMMM').format(date),
                style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('hh:mm a', 'en').format(date),
                style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(String fullPhone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'رقم للتواصل',
                style: GoogleFonts.cairo(fontSize: 10, color: Colors.green[800]),
              ),
              Text(
                fullPhone,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialAlert(bool isRequest, int price) {
    final color = isRequest ? Colors.blue : Colors.orange;
    final icon = isRequest ? Icons.info_outline : Icons.warning_amber_rounded;
    final text = isRequest
        ? 'بموافقتك، أنت تتعهد بتعليم الطالب في هذا الوقت.\nسيتم خصم $price دقيقة من رصيد الطالب فوراً.'
        : 'تأكيدك يعني حجز هذا الموعد وخصم $price دقيقة من رصيدك فوراً.';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.cairo(fontSize: 12, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // --- Logic ---

  // --- (4) منطق فتح الشات الجديد ---
  Future<void> _handleChatAction(BuildContext context) async {
    final myId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    final providerData = widget.service['provider'] ?? widget.service['user'];
    final providerId = providerData != null ? providerData['_id'] : null;

    if (providerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر العثور على بيانات المستخدم')),
      );
      return;
    }

    if (myId == providerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يمكنك مراسلة نفسك!')),
      );
      return;
    }

    // إظهار Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final chatData = await chatProvider.accessChat(providerId);

    if (context.mounted) {
      Navigator.pop(context); // إغلاق الـ Loading

      if (chatData != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chatData['_id'],
              chatName: providerData['name'] ?? 'مستخدم',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء فتح المحادثة')),
        );
      }
    }
  }

  Future<void> _handleBookingAction(
    BuildContext context,
    BookingProvider bookingProvider,
    DateTime serviceDate,
    bool isRequest,
  ) async {
    final success = await bookingProvider.createBooking(
      serviceId: widget.service['_id'],
      date: serviceDate,
      duration: widget.service['price'],
    );

    if (success && context.mounted) {
      if (!isRequest) {
        Provider.of<AuthProvider>(context, listen: false)
            .decreaseLocalBalance(widget.service['price']);
      }

      Provider.of<ServiceProvider>(context, listen: false)
          .removeServiceLocally(widget.service['_id']);

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم الحجز بنجاح!', style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _handleError(context, bookingProvider.errorMessage ?? '', isRequest);
    }
  }

  void _handleError(BuildContext context, String errorMsg, bool isRequest) {
    if (!context.mounted) return;

    bool isBalanceError = errorMsg.contains('رصيد') || errorMsg.contains('كاف');

    if (isBalanceError) {
      if (isRequest) {
        _showDialog(
          context,
          'تنبيه',
          'عذراً، هذا الطالب لا يملك رصيداً كافياً لإتمام الجلسة حالياً.',
          Colors.orange,
        );
      } else {
        _showRechargeDialog(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg, style: GoogleFonts.cairo())),
      );
    }
  }

  void _showDialog(BuildContext context, String title, String content, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: color)),
        content: Text(content, style: GoogleFonts.cairo()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('حسناً', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRechargeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('رصيدك غير كافي 😢', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(
          'لا تملك رصيد دقائق كافٍ لإتمام هذا الحجز.\nهل تريد الذهاب للمتجر لشحن رصيدك؟',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StoreScreen()),
              );
            },
            child: Text('شحن الرصيد', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}