import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentBalance = authProvider.user?.timeBalance ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('المحفظة', style: GoogleFonts.cairo(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCreditCard(currentBalance),
            
            const SizedBox(height: 35),
            
            Text('رصيد مجاني', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            _buildStoreCard(context, title: 'شاهد إعلاناً', subtitle: 'اربح 15 دقيقة فوراً', price: 'مجاني', minutes: 15, icon: Icons.play_circle_fill_rounded, color: Colors.purple, isAd: true),

            const SizedBox(height: 30),

            Text('شراء باقات', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 15),
            _buildStoreCard(context, title: 'باقة البداية', subtitle: 'رصيد 60 دقيقة', price: '3.00 JD', minutes: 60, icon: Icons.local_fire_department_rounded, color: Colors.orange),
            const SizedBox(height: 15),
            _buildStoreCard(context, title: 'باقة المحترف', subtitle: 'رصيد 300 دقيقة (توفير)', price: '10.00 JD', minutes: 300, icon: Icons.diamond_rounded, color: Colors.blue, isBestValue: true),
            
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard(int balance) {
    return Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF283593), AppTheme.primary],
        ),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 15)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(top: -50, right: -50, child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05))),
          Positioned(bottom: -60, left: -30, child: CircleAvatar(radius: 80, backgroundColor: Colors.white.withOpacity(0.05))),

          Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Time Bank', style: GoogleFonts.cairo(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)), const Icon(Icons.nfc, color: Colors.white70)]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الرصيد المتاح', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$balance', style: GoogleFonts.cairo(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, height: 1.0)),
                        const SizedBox(width: 8),
                        Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text('دقيقة', style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16))),
                      ],
                    ),
                  ],
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('**** **** **** Skill', style: GoogleFonts.sourceCodePro(color: Colors.white70, fontSize: 16, letterSpacing: 2)), const Icon(Icons.hourglass_top, color: Colors.white70, size: 20)]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, {required String title, required String subtitle, required String price, required int minutes, required IconData icon, required Color color, bool isAd = false, bool isBestValue = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: isBestValue ? Border.all(color: color.withOpacity(0.5), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () {
            if (isAd) _showAdSimulation(context, minutes);
            else _showPaymentSimulation(context, minutes, price);
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Icon(icon, color: color, size: 32)),
                    const SizedBox(width: 20),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)), Text(subtitle, style: GoogleFonts.cairo(color: Colors.grey[500], fontSize: 13))])),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), decoration: BoxDecoration(color: isAd ? Colors.white : color, border: isAd ? Border.all(color: color) : null, borderRadius: BorderRadius.circular(15), boxShadow: isAd ? null : [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]), child: Text(price, style: GoogleFonts.cairo(color: isAd ? color : Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                  ],
                ),
              ),
              if (isBestValue)
                Positioned(top: 0, left: 0, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.only(topLeft: Radius.circular(22), bottomRight: Radius.circular(22))), child: Text('الأكثر طلباً 🔥', style: GoogleFonts.cairo(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdSimulation(BuildContext context, int minutes) {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 20), Text('جاري تشغيل الإعلان...', style: GoogleFonts.cairo())]))));
    Future.delayed(const Duration(seconds: 2), () { Navigator.pop(context); _addBalanceReal(context, minutes); });
  }

  void _showPaymentSimulation(BuildContext context, int minutes, String price) {
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))), builder: (ctx) => Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [Text('تأكيد الشراء', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('الباقة', style: GoogleFonts.cairo(color: Colors.grey)), Text('$minutes دقيقة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold))]), const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('السعر', style: GoogleFonts.cairo(color: Colors.grey)), Text(price, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 18))]), const SizedBox(height: 30), SizedBox(width: double.infinity, height: 55, child: ElevatedButton(onPressed: () { Navigator.pop(ctx); _addBalanceReal(context, minutes); }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: Text('دفع الآن', style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))))])));
  }

  void _addBalanceReal(BuildContext context, int minutes) {
    Provider.of<AuthProvider>(context, listen: false).increaseLocalBalance(minutes);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم إضافة $minutes دقيقة لرصيدك! 🎉', style: GoogleFonts.cairo()), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), margin: const EdgeInsets.all(20)));
  }
}