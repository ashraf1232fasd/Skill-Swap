import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skill_swap/screens/booking/booking_detail_screen.dart';
import 'package:skill_swap/screens/profile/profile_screen.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/service_provider.dart';
import '../../widgets/service_card.dart';
import '../services/add_service_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String _filterType = 'all'; // all, offer, request

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final user = authProvider.user;

    final filteredServices = serviceProvider.services.where((service) {
      final title = service['title'].toString().toLowerCase();
      final matchesSearch = title.contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == 'all' || service['type'] == _filterType;

      bool isNotMe = true;
      if (service['provider'] != null && user != null) {
        final providerData = service['provider'];
        final providerId = providerData is Map ? providerData['_id'] : providerData.toString();
        isNotMe = providerId != user.id;
      }

      return matchesSearch && matchesType && isNotMe;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildModernHeader(user),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () => serviceProvider.fetchServices(),
              color: AppTheme.primary,
              child: serviceProvider.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  : filteredServices.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 80),
                          itemCount: filteredServices.length,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final service = filteredServices[index];
                            return ServiceCard(
                              service: service,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingScreen(service: service),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddServiceScreen()),
          ).then((_) => serviceProvider.fetchServices());
        },
        backgroundColor: AppTheme.primary,
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildModernHeader(dynamic user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primary.withOpacity(0.7),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً, ${user?.name ?? "زائر"} ',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'اكتشف مهارات جديدة',
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.8), Colors.white],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 23,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: AppTheme.primary, size: 26),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن مهارة...',
                hintStyle: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterChip('الكل', 'all'),
                const SizedBox(width: 10),
                _buildFilterChip('مُعلم (Offer)', 'offer'),
                const SizedBox(width: 10),
                _buildFilterChip('طالب (Request)', 'request'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => setState(() => _filterType = value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              color: isSelected ? Colors.white : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 25, offset: const Offset(0, 10)),
                ],
              ),
              child: Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
            ),
            const SizedBox(height: 25),
            Text(
              "لا توجد نتائج!",
              style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              "جرب البحث عن شيء آخر",
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
