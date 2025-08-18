import 'package:flutter/material.dart';
import 'package:po_app/pages/po_summary_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/dashboard_page.dart';
import '../pages/purchase_order_page.dart';
import '../pages/profile_page.dart';
import '../pages/product_list.dart'; // <-- untuk manajemen produk
import '../providers/purchase_order_provider.dart';
import '../theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String? userRole; // simpan role user
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? 'user';
      _setupPages();
    });
  }

  // void _setupPages() {
  //   // default pages
  //   _pages = [
  //     const PoSummaryPage(),
  //     // const admin.Dashboarage(),
  //     const PurchaseOrderPage(),
  //     const AccountPage(),
  //   ];

  //   // kalau admin, tambahkan menu product
  //   if (userRole == 'admin') {
  //     _pages.insert(2, const ProductListPage());
  //   }
  // }
  void _setupPages() {
    // cek role user
    final isAdminOrMintar = userRole == 'admin' || userRole == 'mitra';

    _pages = [
      isAdminOrMintar ? const PoSummaryPage() : const DashboardPage(),
      const PurchaseOrderPage(),
      const AccountPage(),
    ];

    // kalau admin → tambahin menu produk
    if (userRole == 'admin') {
      _pages.insert(2, const ProductListPage());
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: isSelected ? 28 : 24),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == null) {
      // masih loading role
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => PurchaseOrderProvider(),
      child: Scaffold(
        body: SafeArea(child: _pages[_selectedIndex]),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: AppColors.textSecondary,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            // items: [
            //   _buildNavItem(Icons.dashboard, "Dashboard", _selectedIndex == 0),
            //   _buildNavItem(Icons.list_alt, "PO", _selectedIndex == 1),
            //   if (userRole == 'admin')
            //     _buildNavItem(Icons.inventory, "Produk", _selectedIndex == 2),
            //   _buildNavItem(Icons.person, "Profile",
            //       _selectedIndex == (userRole == 'admin' ? 3 : 2)),
            // ],
            items: [
              _buildNavItem(Icons.dashboard, "Dashboard", _selectedIndex == 0),
              _buildNavItem(Icons.list_alt, "PO", _selectedIndex == 1),
              if (userRole == 'admin')
                _buildNavItem(Icons.inventory, "Produk", _selectedIndex == 2),
              _buildNavItem(
                Icons.person,
                "Profile",
                _selectedIndex == (userRole == 'admin' ? 3 : 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
