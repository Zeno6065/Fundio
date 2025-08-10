import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/app_provider.dart';
import '../../constants/app_theme.dart';
import '../../models/account_model.dart';
import '../account/account_details_screen.dart';
import '../account/join_account_screen.dart';
import '../../widgets/account_card.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshAccounts();
  }

  Future<void> _refreshAccounts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      await accountProvider.loadUserAccounts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load accounts: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToAccountDetails(AccountModel account) {
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);
    accountProvider.selectAccount(account);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AccountDetailsScreen(account: account),
      ),
    );
  }

  void _showJoinAccountModal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JoinAccountScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    final accounts = accountProvider.userAccounts;
    final user = appProvider.user;

    return RefreshIndicator(
      onRefresh: _refreshAccounts,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : accounts.isEmpty
              ? _buildEmptyState()
              : _buildAccountsList(accounts),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_state.png',
              height: 200,
              // If the asset doesn't exist, use a placeholder icon
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.account_balance_wallet_outlined,
                size: 100,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Accounts Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create a new savings account or join an existing one to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // This will be handled by the FAB
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: _showJoinAccountModal,
                  icon: const Icon(Icons.group_add),
                  label: const Text('Join Account'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList(List<AccountModel> accounts) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Your Accounts',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...accounts.map((account) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AccountCard(
                account: account,
                onTap: () => _navigateToAccountDetails(account),
              ),
            )),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _showJoinAccountModal,
          icon: const Icon(Icons.group_add),
          label: const Text('Join Another Account'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            side: BorderSide(color: AppTheme.primaryColor),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 80), // Extra space for FAB
      ],
    );
  }
}