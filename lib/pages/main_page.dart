import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/purchase_order_page.dart';
// import '../pages/add_purchase_order_page.dart' as add_po;
import '../pages/profile_page.dart';
import '../providers/auth_provider.dart';
import '../providers/purchase_order_provider.dart';
import '../theme/app_colors.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const PurchaseOrderPage(), // Tab pertama: PO
    const ProfilePage(), // Tab kedua: Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PurchaseOrderProvider(),
      child: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppColors.primary,
          selectedItemColor: Colors.white,
          unselectedItemColor: AppColors.textSecondary,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "PO"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
