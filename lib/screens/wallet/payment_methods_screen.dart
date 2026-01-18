import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../providers/wallet_provider.dart'; 

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedCardId = 1;

  // الكنترولرز
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _holderController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _holderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    final savedCards = walletProvider.savedCards;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text('طرق الدفع', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البطاقات المحفوظة',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (savedCards.isEmpty)
              const Center(child: Text("لا توجد بطاقات محفوظة"))
            else
              ...savedCards.map((card) => _buildCreditCard(card)).toList(),

            const SizedBox(height: 20),

            InkWell(
              onTap: _showAddCardSheet,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline, color: AppTheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'إضافة بطاقة جديدة',
                      style: GoogleFonts.cairo(color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCard(Map<String, dynamic> card) {
    bool isSelected = _selectedCardId == card['id'];

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCardId = card['id']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              card['color'],
              card['color'].withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: card['color'].withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: CircleAvatar(radius: 50, backgroundColor: Colors.white.withOpacity(0.1)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        card['type'] == 'visa' ? Icons.payment : Icons.credit_card, 
                        color: Colors.white, 
                        size: 30
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: Colors.white, size: 24),
                    ],
                  ),
                  
                  Text(
                    card['number'],
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.white,
                      fontSize: 22,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Holder', style: GoogleFonts.cairo(color: Colors.white60, fontSize: 10)),
                          Text(card['holder'], style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expires', style: GoogleFonts.cairo(color: Colors.white60, fontSize: 10)),
                          Text(card['expiry'], style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardSheet() {
    _numberController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _holderController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, 
          left: 20, 
          right: 20, 
          top: 25
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text('إضافة بطاقة جديدة', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            TextField(
              controller: _numberController,
              keyboardType: TextInputType.number,
              decoration: _inputDec('رقم البطاقة (16 خانة)', Icons.credit_card),
            ),
            const SizedBox(height: 15),
            
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    keyboardType: TextInputType.datetime,
                    decoration: _inputDec('MM/YY', Icons.date_range),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    decoration: _inputDec('CVV', Icons.lock_outline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _holderController,
              decoration: _inputDec('اسم حامل البطاقة', Icons.person_outline),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  if (_numberController.text.isNotEmpty && _holderController.text.isNotEmpty) {
                    Provider.of<WalletProvider>(context, listen: false).addCard(
                      number: _numberController.text,
                      holder: _holderController.text,
                      expiry: _expiryController.text,
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة البطاقة بنجاح ✅')));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Text('حفظ البطاقة', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 22, color: AppTheme.primary),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary)),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
    );
  }
}