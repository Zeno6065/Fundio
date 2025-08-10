import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../providers/account_provider.dart';
import '../../constants/app_theme.dart';
import '../account/create_account_screen.dart';
import '../account/account_details_screen.dart';
import '../profile/profile_screen.dart';
import 'dashboard_tab.dart';
import '../../widgets/theme_toggle_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [
    const DashboardTab(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserAccounts();
  }

  Future<void> _loadUserAccounts() async {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    await accountProvider.loadUserAccounts();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showCreateAccountModal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fundio'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications screen
            },
          ),
          const ThemeToggleButton(iconColor: Colors.white),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: _showCreateAccountModal,
              backgroundColor: AppTheme.primaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}