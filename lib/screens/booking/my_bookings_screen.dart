import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// >>>>> التعديل هنا: إخفاء TextDirection لمنع الخطأ <<<<<
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final myId = Provider.of<AuthProvider>(context, listen: false).user?.id;

    // تصفية القوائم
    final sentBookings = bookingProvider.bookings.where((b) {
      if (b == null || b['student'] == null) return false;
      return b['student']['_id'] == myId;
    }).toList();

    final receivedBookings = bookingProvider.bookings.where((b) {
       if (b == null || b['provider'] == null) return false;
       return b['provider']['_id'] == myId;
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA), // خلفية عصرية
        body: Column(
          children: [
            // 1. الهيدر المخصص مع التبويبات
            _buildCustomHeader(),

            // 2. محتوى القوائم
            Expanded(
              child: bookingProvider.isLoading
                  ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : TabBarView(
                      children: [
                        _buildBookingList(sentBookings, isReceived: false),
                        _buildBookingList(receivedBookings, isReceived: true),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // تصميم الهيدر والتاب بار
  Widget _buildCustomHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // الصف العلوي (زر الرجوع والعنوان)
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'سجل الحجوزات',
                    style: TextStyle(
                      fontFamily: 'Cairo', 
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40), // لموازنة زر الرجوع
            ],
          ),
          const SizedBox(height: 20),
          
          // التبويبات بتصميم Bubble
          Container(
            height: 50,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: AppTheme.primary,
              unselectedLabelColor: Colors.white,
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'طلباتي المرسلة'),
                Tab(text: 'الطلبات الواردة'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingList(List<dynamic> bookings, {required bool isReceived}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)],
              ),
              child: Icon(
                isReceived ? Icons.inbox_outlined : Icons.send_outlined, 
                size: 50, 
                color: Colors.grey[400]
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد حجوزات في هذه القائمة',
              style: GoogleFonts.cairo(color: Colors.grey[600], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 40),
      itemCount: bookings.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        if (booking == null || booking['service'] == null || booking['student'] == null || booking['provider'] == null) {
          return const SizedBox.shrink(); 
        }

        final status = booking['status'] ?? 'pending';
        DateTime date;
        try { date = DateTime.parse(booking['date']); } catch (_) { date = DateTime.now(); }
        final totalCost = booking['totalCost'] ?? booking['duration'] ?? 0;
        
        final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);

        // تصميم الكرت الحديث
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رأس الكرت: التاريخ + الحالة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                             DateFormat('MMM dd, hh:mm a').format(date.toLocal()),
                             style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                             textDirection: TextDirection.ltr, // الآن تعمل بشكل صحيح
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(status),
                  ],
                ),
                
                const SizedBox(height: 12),

                // العنوان
                Text(
                  booking['service']['title'] ?? 'خدمة محذوفة',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // معلومات الطرف الآخر
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isReceived ? Colors.purple.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                      child: Icon(
                        isReceived ? Icons.person : Icons.school, 
                        size: 14, 
                        color: isReceived ? Colors.purple : Colors.blue
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isReceived 
                          ? 'الطالب: ${booking['student']['name'] ?? "غير معروف"}' 
                          : 'المعلم: ${booking['provider']['name'] ?? "غير معروف"}',
                      style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
                
                // الأزرار التفاعلية
                if (isReceived && (status == 'pending' || status == 'accepted')) ...[
                   const Padding(
                     padding: EdgeInsets.symmetric(vertical: 12),
                     child: Divider(height: 1),
                   ),
                   _buildActionButtons(context, booking, status, totalCost, bookingProvider, authProvider),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // قسم الأزرار
  Widget _buildActionButtons(
    BuildContext context, 
    dynamic booking, 
    String status, 
    dynamic totalCost,
    BookingProvider bookingProvider, 
    AuthProvider authProvider
  ) {
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                 final success = await bookingProvider.updateBookingStatus(booking['_id'], 'cancelled');
                 if(success && context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم رفض الطلب")));
                 }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('رفض', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () async {
                await bookingProvider.updateBookingStatus(booking['_id'], 'accepted');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Center(
                  child: Text('قبول الطلب', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      );
    } 
    
    if (status == 'accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
             final success = await bookingProvider.updateBookingStatus(booking['_id'], 'completed');
             if (success && context.mounted) {
               authProvider.increaseLocalBalance(totalCost);
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('مبروك! تمت إضافة الرصيد لحسابك 💰')),
               );
             }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 4,
          ),
          child: const Text(
            '✅ إتمام الجلسة واستلام الرصيد',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'انتظار';
        icon = Icons.access_time_filled;
        break;
      case 'accepted':
        color = Colors.green;
        text = 'مقبول';
        icon = Icons.check_circle;
        break;
      case 'completed':
        color = Colors.blue;
        text = 'مكتمل';
        icon = Icons.task_alt;
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'ملغي';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.cairo(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}