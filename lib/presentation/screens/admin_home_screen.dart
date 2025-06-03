import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twh/presentation/screens/all_deals_screen.dart';
import 'package:twh/presentation/screens/registeration_screen.dart';
import 'package:twh/presentation/screens/user_deals_screen.dart';
import 'package:twh/presentation/widgets/connectivity_banner.dart';
import 'package:twh/presentation/widgets/loading.dart';
import 'login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  Future<List<Map<String, dynamic>>>? usersFuture;
  Future<Map<String, int>>? statsFuture;

  String? currentBranch;
  String? currentRole;
  String? currentName;
  String searchText = '';
  String selectedBranch = 'All';
  String selectedRole = 'staff';

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final data = userDoc.data();
    currentBranch = data?['branch'];
    currentRole = data?['role'];
    currentName = data?['name'] ?? 'Admin';

    _loadData();
  }

  void _loadData() {
    setState(() {
      usersFuture = fetchUsersWithDeals(
        branchFilter: currentRole == 'branch_manager'
            ? currentBranch
            : (selectedBranch == 'All' ? null : selectedBranch),
        roleFilter: selectedRole,
        searchFilter: searchText,
      );
      statsFuture = fetchDealStats(
        branchFilter: currentRole == 'branch_manager'
            ? currentBranch
            : (selectedBranch == 'All' ? null : selectedBranch),
      );
    });
  }

  Future<List<Map<String, dynamic>>> fetchUsersWithDeals({
    String? branchFilter,
    String roleFilter = 'staff',
    String searchFilter = '',
  }) async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    List<Map<String, dynamic>> result = [];

    for (var userDoc in usersSnapshot.docs) {
      final data = userDoc.data();
      if (data['role'] != roleFilter) continue;
      if (branchFilter != null && data['branch'] != branchFilter) continue;
      if (searchFilter.isNotEmpty &&
          !(data['email'] ?? '')
              .toLowerCase()
              .contains(searchFilter.toLowerCase())) {
        continue;
      }

      final formsSnapshot = await userDoc.reference.collection('forms').get();
      result.add({
        'email': data['email'] ?? 'Unknown',
        'dealCount': formsSnapshot.size,
        'uid': userDoc.id,
      });
    }

    return result;
  }

  Future<Map<String, int>> fetchDealStats({String? branchFilter}) async {
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    int total = 0, done = 0, pending = 0, noDeal = 0;

    for (var userDoc in usersSnapshot.docs) {
      final data = userDoc.data();
      if (data['role'] != 'staff') continue;
      if (branchFilter != null && data['branch'] != branchFilter) continue;

      final formsSnapshot = await userDoc.reference.collection('forms').get();
      for (var form in formsSnapshot.docs) {
        final status = form.data()['deal_status'] ?? 'pending';
        total++;
        if (status == 'done')
          done++;
        else if (status == 'no_deal')
          noDeal++;
        else
          pending++;
      }
    }

    return {
      'total': total,
      'done': done,
      'pending': pending,
      'no_deal': noDeal,
    };
  }

  Widget _buildStatBox(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          "$count",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  void _openRegistration() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(currentName ?? 'Admin'),
              subtitle: Text("($currentRole)"),
            ),
            // if (currentRole != null)
            //   ListTile(
            //     leading: const Icon(Icons.location_on),
            //     title: const Text("Role"),
            //     subtitle: Text(currentRole!),
            //   ),
            // ListTile(
            //   leading: const Icon(Icons.lock),
            //   title: const Text("Change Password"),
            //   onTap: () {
            //     Navigator.pop(context);
            //     // Implement your change password flow here
            //   },
            // ),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text("Logout"),
              onTap: _logout,
            ),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Admin Dashboard',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A2E76)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Color(0xFF6A2E76)),
            onPressed: _showProfileMenu,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openRegistration,
        backgroundColor: const Color(0xFF6A2E76),
        child: const Icon(
          Icons.person_add_alt_1,
          color: Colors.white,
        ),
        tooltip: 'Add New User',
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async => _loadData(),
            color: const Color(0xFF6A2E76),
            child: FutureBuilder<Map<String, int>>(
              future: statsFuture,
              builder: (context, statsSnapshot) {
                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: usersFuture,
                  builder: (context, usersSnapshot) {
                    if (statsSnapshot.connectionState ==
                            ConnectionState.waiting ||
                        usersSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const Center(child: AppLoader());
                    }

                    final stats = statsSnapshot.data ??
                        {'total': 0, 'done': 0, 'pending': 0, 'no_deal': 0};
                    final users = usersSnapshot.data ?? [];

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Image.asset('assets/logo.png', height: 60),
                        const SizedBox(height: 12),
                        Text(
                          'Hello, ${currentName ?? 'Admin'} 👋',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6A2E76),
                          ),
                        ),
                        if (selectedBranch != 'All')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Color(0xFF6A2E76), size: 20),
                                const SizedBox(width: 6),
                                Text(
                                  '$selectedBranch Branch',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF6A2E76),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          color: Colors.white,
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("📈 Deals Summary",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatBox(
                                        "Total",
                                        stats['total']!,
                                        const Color(0xFF6A2E76),
                                        Icons.analytics),
                                    _buildStatBox("Done", stats['done']!,
                                        Colors.green, Icons.check_circle),
                                    _buildStatBox("Pending", stats['pending']!,
                                        Colors.orange, Icons.timelapse),
                                    _buildStatBox("No Deal", stats['no_deal']!,
                                        Colors.red, Icons.cancel),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AllDealsScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A2E76),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.list_alt),
                                  SizedBox(width: 8),
                                  Text("📋 View All Deals"),
                                ],
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text("👥 Users",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),

                        // 🔎 Search & Filters
                        Row(
                          children: [
                            // Expanded(
                            //   child: TextField(
                            //     controller: searchController,
                            //     decoration: InputDecoration(
                            //       hintText: 'Search by email',
                            //       prefixIcon: const Icon(Icons.search),
                            //       filled: true,
                            //       fillColor: Colors.white,
                            //       contentPadding:
                            //           const EdgeInsets.symmetric(horizontal: 12),
                            //       border: OutlineInputBorder(
                            //         borderRadius: BorderRadius.circular(10),
                            //         borderSide: BorderSide.none,
                            //       ),
                            //     ),
                            //     onChanged: (value) {
                            //       setState(() {
                            //         searchText = value;
                            //         _loadData();
                            //       });
                            //     },
                            //   ),
                            // ),
                            // const SizedBox(width: 10),
                            if (currentRole != 'branch_manager')
                              DropdownButton<String>(
                                value: selectedRole,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'staff', child: Text('Staff')),
                                  DropdownMenuItem(
                                      value: 'branch_manager',
                                      child: Text('Branch Mgr')),
                                  DropdownMenuItem(
                                      value: 'retail_manager',
                                      child: Text('Retail Mgr')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedRole = value!;
                                    _loadData();
                                  });
                                },
                              ),
                            if (currentRole != 'branch_manager')
                              const SizedBox(width: 10),
                            if (currentRole != 'branch_manager')
                              DropdownButton<String>(
                                value: selectedBranch,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'All',
                                      child: Text('All Branches')),
                                  DropdownMenuItem(
                                      value: 'Cairo festival city',
                                      child: Text('Cairo festival city')),
                                  DropdownMenuItem(
                                      value: 'City Center Almaza',
                                      child: Text('City Center Almaza')),
                                  DropdownMenuItem(
                                      value: 'Mall Of Egypt',
                                      child: Text('Mall Of Egypt')),
                                  DropdownMenuItem(
                                      value: 'City Center Alexanderia',
                                      child: Text('City Center Alexanderia')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedBranch = value!;
                                    _loadData();
                                  });
                                },
                              ),
                          ],
                        ),
                        // const SizedBox(height: 20),

                        // 📊 Stats Card

                        if (users.isEmpty)
                          const Center(
                              child: Text("No matching users.",
                                  style: TextStyle(color: Colors.grey))),
                        ...users.map((user) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserDealsScreen(
                                      userId: user['uid'],
                                      userEmail: user['email'],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 22,
                                      backgroundColor: Color(0xFF6A2E76),
                                      child: Icon(Icons.person,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            user['email'],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            'Tap to view deals',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8DAEF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${user['dealCount']} Deals',
                                        style: const TextStyle(
                                          color: Color(0xFF6A2E76),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ConnectivityBanner(),
          ),
        ],
      ),
    );
  }
}
