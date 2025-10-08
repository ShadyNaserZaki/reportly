import 'package:flutter/material.dart';
import 'package:reportly/screens/login_screen.dart';
import 'package:reportly/services/api_service.dart';
import 'package:reportly/services/storage_service.dart';
import 'package:reportly/theme_colors.dart';

class ReportlyDashboard extends StatefulWidget {
  const ReportlyDashboard({super.key});

  @override
  State<ReportlyDashboard> createState() => _ReportlyDashboardState();
}

class _ReportlyDashboardState extends State<ReportlyDashboard> {
  int _selectedIndex = 0;
  late Future<Map<String, dynamic>?> _userFuture;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      final dio = ApiService().dio;
      final response = await dio.get('/auth/me');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['user'];
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _userFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final user = snapshot.data;

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _userFuture = _fetchUserData();
                  });
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Header with user data
                      Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withAlpha(200),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(77),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // User Avatar
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(40),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),

                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'أهلًا،',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white.withAlpha(230),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user != null
                                        ? '${user['firstName']} ${user['lastName']}'
                                        : 'المستخدم',
                                    style: AppTextStyles.heading2.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(40),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      user != null
                                          ? (user['role'] == 'admin'
                                          ? 'مدير النظام'
                                          : 'مستخدم')
                                          : '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Logout Button
                            InkWell(
                              onTap: () async {
                                await StorageService.clearStorage();
                                if (context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginScreen()),
                                        (route) => false,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(51),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 🔹 Overview Section
                      Text(
                        'نظرة عامة',
                        style: AppTextStyles.heading2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 🔹 Stats Cards
                      _buildModernStatCard(
                        title: 'إجمالي المبيعات',
                        value: '١٬٢٣٤',
                        icon: Icons.trending_up_rounded,
                        gradientColors: [
                          AppColors.secondary,
                          AppColors.secondary.withAlpha(180),
                        ],
                        iconBg: AppColors.secondary.withAlpha(40),
                      ),
                      const SizedBox(height: 16),

                      _buildModernStatCard(
                        title: 'إجمالي المستلم',
                        value: '٥٬٦٧٨',
                        icon: Icons.account_balance_wallet_outlined,
                        gradientColors: [
                          AppColors.primary,
                          AppColors.primary.withAlpha(180),
                        ],
                        iconBg: AppColors.primary.withAlpha(40),
                      ),
                      const SizedBox(height: 16),

                      _buildModernStatCard(
                        title: 'التقارير هذا الأسبوع',
                        value: '٤٢',
                        icon: Icons.assessment_outlined,
                        gradientColors: [
                          const Color(0xFF6C63FF),
                          const Color(0xFF6C63FF).withAlpha(180),
                        ],
                        iconBg: const Color(0xFF6C63FF).withAlpha(40),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // 🔹 Floating Action Button
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          label: Text(
            'تقرير جديد',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 8,
        ),

        // 🔹 Bottom Navigation Bar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTextStyles.bodySmall,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard_rounded),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.description_outlined),
                activeIcon: Icon(Icons.description_rounded),
                label: 'التقارير',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'الملف الشخصي',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    required Color iconBg,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withAlpha(90),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withAlpha(220),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    value,
                    style: AppTextStyles.numberLarge.copyWith(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
          ],
        ),
      ),
    );
  }
}
