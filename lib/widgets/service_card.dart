import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';

class ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- استخراج البيانات (كما هو في الكود الأصلي تماماً) ---
    final title = service['title'] ?? 'بدون عنوان';
    final price = service['price'] ?? 0;
    final category = service['category'] ?? 'عام';

    String providerName = 'مستخدم Skill Swap';
    if (service['provider'] != null && service['provider'] is Map) {
      providerName = service['provider']['name'] ?? 'مستخدم';
    } else if (service['user'] != null && service['user'] is Map) {
      providerName = service['user']['name'] ?? 'مستخدم';
    }

    final isRequest = service['type'] == 'request';
    final String roleLabel = isRequest ? 'طالب (يطلب مهارة)' : 'مُعلم (يعرض مهارة)';
    final Color roleColor = isRequest ? Colors.orange : AppTheme.primary;
    // تم تغيير الأيقونة قليلاً لتكون أكثر عصرية
    final IconData roleIcon = isRequest ? Icons.search_rounded : Icons.workspace_premium_rounded;

    // --- بداية التصميم ---
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // حواف أكثر استدارة
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF909090).withOpacity(0.08), // ظل ناعم جداً
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // زينة خلفية (دائرة باهتة)
              Positioned(
                left: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. السطر العلوي: الشارة (Tag) + الفئة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // شارة الدور (التصميم الجديد)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: roleColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(roleIcon, size: 14, color: roleColor),
                              const SizedBox(width: 6),
                              Text(
                                roleLabel,
                                style: GoogleFonts.cairo(
                                  color: roleColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // الفئة (Category)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 2. العنوان
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 17, // تكبير الخط قليلاً
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 16),
                    Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                    const SizedBox(height: 12),

                    // 3. السطر السفلي: المستخدم + السعر
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // معلومات المستخدم
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: roleColor.withOpacity(0.2), width: 1.5),
                                ),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.grey[100],
                                  child: Icon(Icons.person, size: 16, color: Colors.grey[400]),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      providerName,
                                      style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'المستخدم', // نص إضافي صغير للتوثيق البصري
                                      style: GoogleFonts.cairo(
                                        fontSize: 9,
                                        color: Colors.grey[500],
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // السعر / الوقت
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_filled_rounded, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                '$price دقيقة',
                                style: GoogleFonts.cairo(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w800, // خط سميك للأرقام
                                  fontSize: 12,
                                ),
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
          ),
        ),
      ),
    );
  }
}