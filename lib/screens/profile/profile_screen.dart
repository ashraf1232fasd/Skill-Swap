import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../auth/login_screen.dart';
import '../../widgets/service_card.dart';
import '../booking/my_bookings_screen.dart';
import '../wallet/store_screen.dart';
import '../wallet/payment_methods_screen.dart'; 

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    
    final user = authProvider.user;

    final myServices = serviceProvider.services.where((s) {
      final providerData = s['provider'];
      if (providerData == null) return false;
      
      if (providerData is Map) {
        return providerData['_id'] == user?.id;
      }
      return providerData.toString() == user?.id;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 240,
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
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () => _showLogoutConfirm(context),
                  ),
                ),
                
                Positioned(
                  top: 160,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          user?.name ?? 'مستخدم',
                          style: GoogleFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          user?.email ?? '',
                          style: GoogleFonts.cairo(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.grey, thickness: 0.2),
                        const SizedBox(height: 10),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('الرصيد', '${user?.timeBalance ?? 0} د', Colors.blue),
                            Container(width: 1, height: 40, color: Colors.grey[200]),
                            _buildStatItem('منشوراتي', '${myServices.length}', Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                Positioned(
                  top: 110,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[100],
                      child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 160),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  _buildMenuButton(
                    context,
                    title: 'سجل الطلبات',
                    subtitle: 'تتبع حالتك وحجوزاتك',
                    icon: Icons.calendar_month,
                    iconColor: const Color(0xFF4CAF50),
                    bgColor: const Color(0xFFE8F5E9),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen())),
                  ),
                  
                  const SizedBox(height: 15),

                  _buildMenuButton(
                    context,
                    title: 'المحفظة والشحن',
                    subtitle: 'زيادة رصيد الوقت',
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.deepPurple,
                    bgColor: const Color(0xFFEDE7F6),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen())),
                  ),

                  const SizedBox(height: 15),

                  _buildMenuButton(
                    context,
                    title: 'طرق الدفع',
                    subtitle: 'إدارة بطاقاتك البنكية',
                    icon: Icons.credit_card,
                    iconColor: const Color(0xFF1565C0), 
                    bgColor: const Color(0xFFE3F2FD),   
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Row(
                children: [
                  Container(width: 4, height: 20, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    'منشوراتي النشطة',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 15),

            if (myServices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Icon(Icons.dashboard_customize_outlined, size: 60, color: Colors.grey[300]),
                    Text('لا يوجد منشورات', style: GoogleFonts.cairo(color: Colors.grey)),
                  ],
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myServices.length,
                itemBuilder: (context, index) {
                  final service = myServices[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ServiceCard(service: service, onTap: () {}),
                        InkWell(
                          onTap: () => _showDeleteConfirm(context, serviceProvider, service['_id']),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'حذف المنشور',
                                  style: GoogleFonts.cairo(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
             
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context, ServiceProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            const SizedBox(width: 10),
            Text('تنبيه', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('هل تريد حذف هذا المنشور نهائياً؟', style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text('تراجع', style: GoogleFonts.cairo(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.deleteService(id);
              if(context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف')));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('حذف', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout, size: 50, color: Colors.red),
            const SizedBox(height: 20),
            Text('تسجيل الخروج', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('هل أنت متأكد أنك تريد المغادرة؟', style: GoogleFonts.cairo(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey))
          ),
          TextButton(
            onPressed: () {
               Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
            },
            child: Text('خروج', style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}