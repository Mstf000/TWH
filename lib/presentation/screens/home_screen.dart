import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twh/data/services/firestore_service.dart';
import '../../core/utils/translations.dart';
import '../providers/locale_provider.dart';
import '../viewmodel/auth_viewmodel.dart';
import 'customer_info_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final auth = context.read<AuthViewModel>();
    final fullEmail = auth.currentUser?.email ?? 'Guest';
    final username =
        fullEmail.contains('@') ? fullEmail.split('@')[0] : fullEmail;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9F6FB), Color(0xFFE8DAEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with logo, lang toggle, logout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Hero(
                  tag: 'twh_logo',
                  child: Image.asset(
                    'assets/logo.png',
                    height: 50,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Text(locale == 'en' ? '🇸🇦' : '🇬🇧',
                          style: const TextStyle(fontSize: 18)),
                      onPressed: () =>
                          context.read<LocaleProvider>().toggleLocale(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Logout',
                      onPressed: () {
                        auth.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 32),

            // Welcome & user email
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    translations['welcome']![locale]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6A2E76),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    locale == 'ar' ? 'مرحبًا، $username' : 'Welcome, $username',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        locale == 'ar' ? 'الصفقات السابقة' : 'Previous Deals',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A2E76),
                        ),
                      ),
                      FutureBuilder<int>(
                        future: FirestoreService().getUserFormCount(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          final count = snapshot.data ?? 0;
                          return Text(
                            locale == 'ar'
                                ? 'عدد الصفقات: $count'
                                : 'Deals: $count',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, String>>>(
                    future: FirestoreService().getUserDealsWithStatus(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final deals = snapshot.data ?? [];

                      if (deals.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              locale == 'ar'
                                  ? 'لا توجد صفقات بعد'
                                  : 'No deals submitted yet',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 120,
                        child: ListView.separated(
                          padding: const EdgeInsets.only(top: 8),
                          itemCount: deals.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 16),
                          itemBuilder: (context, index) {
                            final deal = deals[index];
                            final status = deal['status'];
                            final icon = status == 'done'
                                ? const Icon(Icons.check_circle,
                                    color: Colors.green)
                                : status == 'pending'
                                    ? const Icon(Icons.timelapse,
                                        color: Colors.orange)
                                    : const Icon(Icons.cancel,
                                        color: Colors.red);

                            return Row(
                              children: [
                                icon,
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    deal['name'] ?? '',
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  )
                ],
              ),
            ),

            // Main Card
            Expanded(
              child: Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/massage-chair.png',
                        height: 70,
                      ),
                      const SizedBox(height: 24),
                      Hero(
                        tag: 'start_deal_btn',
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          label: Text(translations['start_deal']![locale]!),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CustomerInfoScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
