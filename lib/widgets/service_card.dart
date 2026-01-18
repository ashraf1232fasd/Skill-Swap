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
    final title = service['title'] ?? 'بدون عنوان';
    final price = service['price'] ?? 0;
    final category = service['category'] ?? 'عام';

    // استخراج اسم المستخدم
    String providerName = 'مستخدم Skill Swap';
    if (service['provider'] != null && service['provider'] is Map) {
      providerName = service['provider']['name'] ?? 'مستخدم';
    } else if (service['user'] != null && service['user'] is Map) {
      providerName = service['user']['name'] ?? 'مستخدم';
    }

    final isRequest = service['type'] == 'request';
    
    final String roleLabel = isRequest ? 'طالب (يطلب مهارة)' : 'مُعلم (يعرض مهارة)';
    final Color roleColor = isRequest ? Colors.orange : AppTheme.primary;
    final IconData roleIcon = isRequest ? Icons.help_outline : Icons.school_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. الصف العلوي: الشارة (معلم/طالب) + السعر
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // شارة الدور (معلم أو طالب)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        // خلفية خفيفة بلون الدور
                        color: roleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: roleColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(roleIcon, size: 16, color: roleColor),
                          const SizedBox(width: 6),
                          Text(
                            roleLabel, // هنا سيظهر النص بوضوح
                            style: GoogleFonts.cairo(
                              color: roleColor, // لون النص نفس لون الدور
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // السعر
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '$price دقيقة',
                          style: GoogleFonts.cairo(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 2. العنوان
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey[200]),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.grey[100],
                            child: Icon(Icons.person, size: 14, color: Colors.grey[400]),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              providerName,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      category,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}