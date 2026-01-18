import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../core/theme.dart';
import '../../providers/service_provider.dart';
import '../wallet/store_screen.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryCodeController = TextEditingController(text: '+962');
  
  final _customCategoryController = TextEditingController();

  String _selectedType = 'offer';
  String? _selectedCategory;
  final List<String> categories = ['برمجة', 'تطوير ذات', 'لغات', 'تصميم', 'أخرى'];

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _phoneController.dispose();
    _countryCodeController.dispose();
    _customCategoryController.dispose(); 
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppTheme.primary)),
        child: child!,
      ),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;
    setState(() {
      _selectedDate = date;
      _selectedTime = time;
    });
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);

    DateTime? finalDateTime;
    if (_selectedDate != null && _selectedTime != null) {
      finalDateTime = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _selectedTime!.hour, _selectedTime!.minute);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('إضافة خدمة جديدة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("نوع الخدمة", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildTypeSelector('أريد أن أُعَلِّم', 'offer', Icons.school_outlined, const Color(0xFF4CAF50))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTypeSelector('أريد أن أتعلم', 'request', Icons.handshake_outlined, const Color(0xFFFF9800))),
                ],
              ),
              const SizedBox(height: 24),

              Text("التفاصيل الأساسية", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50], 
                    border: Border.all(
                      color: finalDateTime == null && _autovalidateMode == AutovalidateMode.always 
                          ? Colors.red 
                          : Colors.grey.shade200
                    ), 
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: finalDateTime == null && _autovalidateMode == AutovalidateMode.always ? Colors.red : AppTheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        finalDateTime == null ? 'حدد الموعد (إجباري)' : DateFormat('yyyy-MM-dd – hh:mm a').format(finalDateTime),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold, 
                          color: finalDateTime == null ? ( _autovalidateMode == AutovalidateMode.always ? Colors.red : Colors.grey[600]) : Colors.black87, 
                          fontSize: 15
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextFormField(
                        controller: _countryCodeController,
                        decoration: _buildInputDecoration('', Icons.flag_outlined).copyWith(hintText: '+962'),
                        keyboardType: TextInputType.phone,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'مطلوب';
                          if (!value.startsWith('+')) return 'ابدأ بـ +';
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: _buildInputDecoration('رقم الهاتف', Icons.phone_outlined),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'رقم الهاتف مطلوب';
                          if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'أرقام فقط';
                          if (value.length < 9) return 'الرقم قصير جداً';
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration('عنوان الخدمة', Icons.title),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'العنوان مطلوب';
                  if (value.length < 3) return 'العنوان قصير جداً';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // >>>>> القائمة المنسدلة للتصنيف <<<<<
              DropdownButtonFormField(
                value: _selectedCategory,
                items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedCategory = v;
                    // إذا غير رأيه عن "أخرى"، نفرغ الحقل المخصص
                    if (v != 'أخرى') {
                      _customCategoryController.clear();
                    }
                  });
                },
                decoration: _buildInputDecoration('التصنيف', Icons.category_outlined),
                icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                validator: (v) => v == null ? 'يرجى اختيار تصنيف' : null,
              ),
              
              // >>>>> 2. حقل يظهر فقط إذا اختار "أخرى" <<<<<
              if (_selectedCategory == 'أخرى') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customCategoryController,
                  decoration: _buildInputDecoration('حدد التصنيف (اكتبه هنا)', Icons.edit),
                  validator: (value) {
                    // التحقق من الحقل فقط إذا كان ظاهراً
                    if (_selectedCategory == 'أخرى' && (value == null || value.isEmpty)) {
                      return 'يرجى كتابة التصنيف';
                    }
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: _buildInputDecoration('الوصف والتفاصيل', Icons.description_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'الوصف مطلوب';
                  if (value.length < 10) return 'اكتب وصفاً مفيداً (10 أحرف ع الأقل)';
                  return null;
                },
              ),
              const SizedBox(height: 40),

              if (serviceProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _autovalidateMode = AutovalidateMode.always;
                      });

                      if (_formKey.currentState!.validate()) {
                        if (finalDateTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تحديد الوقت والتاريخ'), backgroundColor: Colors.red));
                          return;
                        }

                        // >>>>> 3. تحديد التصنيف النهائي للإرسال <<<<<
                        String finalCategoryToSend = _selectedCategory!;
                        if (_selectedCategory == 'أخرى') {
                          finalCategoryToSend = _customCategoryController.text;
                        }

                        try {
                          final success = await serviceProvider.createService(
                            title: _titleController.text,
                            description: _descController.text,
                            category: finalCategoryToSend, // نرسل القيمة النهائية
                            type: _selectedType,
                            datetime: finalDateTime,
                            countryCode: _countryCodeController.text,
                            phone: _phoneController.text,
                          );

                          if (success && context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم نشر الخدمة بنجاح ✅', style: GoogleFonts.cairo()), backgroundColor: Colors.green));
                          }
                        } catch (e) {
                          String errorMsg = e.toString();
                          if (errorMsg.contains('رصيد') || errorMsg.contains('Balance')) {
                            if (context.mounted) _showLowBalanceDialog(context, errorMsg);
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg, style: GoogleFonts.cairo()), backgroundColor: Colors.red));
                            }
                          }
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('يرجى تصحيح الأخطاء في الحقول', style: GoogleFonts.cairo()), backgroundColor: Colors.orange),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Text('نشر الخدمة', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showLowBalanceDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.red, size: 30),
            const SizedBox(width: 10),
            Text('الرصيد غير كافٍ', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.replaceAll("Exception:", "").trim(), style: GoogleFonts.cairo(fontSize: 14)),
            const SizedBox(height: 20),
            Text('هل تود الانتقال للمحفظة لشحن رصيدك؟', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StoreScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('شحن الرصيد 💰', style: GoogleFonts.cairo(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(String title, String val, IconData icon, Color color) {
    bool selected = _selectedType == val;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(color: selected ? color : Colors.grey.shade300, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? color : Colors.grey, size: 28),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.cairo(color: selected ? color : Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}