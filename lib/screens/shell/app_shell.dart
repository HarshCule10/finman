import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../balances/balances_screen.dart';
import '../profile/profile_screen.dart';

/// Root navigation container managing bottom navigation and screen switching.
/// Uses IndexedStack to preserve state across tab switches.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<Widget> _screens = const [
    HomeScreen(),
    BalancesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    // Trigger scale animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentIndex,
      children: _screens,
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.home_outlined, 0),
              activeIcon: _buildAnimatedIcon(Icons.home, 0),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.account_balance_wallet_outlined, 1),
              activeIcon: _buildAnimatedIcon(Icons.account_balance_wallet, 1),
              label: 'Balances',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.person_outline, 2),
              activeIcon: _buildAnimatedIcon(Icons.person, 2),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ScaleTransition(
        scale: _currentIndex == index ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
        child: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
