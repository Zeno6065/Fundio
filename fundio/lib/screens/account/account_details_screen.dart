import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/account_model.dart';
import '../../models/deposit_model.dart';
import '../../providers/account_provider.dart';
import '../../providers/deposit_provider.dart';
import '../../providers/withdrawal_provider.dart';
import '../../widgets/deposit_card.dart';
import '../../widgets/withdrawal_card.dart';
import '../../widgets/theme_toggle_button.dart';
import 'create_deposit_screen.dart';
import 'create_withdrawal_screen.dart';

class AccountDetailsScreen extends StatefulWidget {
  final Account account;

  const AccountDetailsScreen({Key? key, required this.account}) : super(key: key);

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final depositProvider = Provider.of<DepositProvider>(context, listen: false);
      final withdrawalProvider = Provider.of<WithdrawalProvider>(context, listen: false);
      
      await depositProvider.loadAccountDeposits(widget.account.id);
      await withdrawalProvider.loadAccountWithdrawals(widget.account.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
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

  void _navigateToCreateDeposit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateDepositScreen(account: widget.account),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToCreateWithdrawal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWithdrawalScreen(account: widget.account),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    final depositProvider = Provider.of<DepositProvider>(context);
    final withdrawalProvider = Provider.of<WithdrawalProvider>(context);
    final accountProvider = Provider.of<AccountProvider>(context);
    
    // Get the current account with updated data
    final currentAccount = accountProvider.accounts.firstWhere(
      (a) => a.id == widget.account.id,
      orElse: () => widget.account,
    );

    // Calculate progress percentage
    final double progressPercentage = currentAccount.targetAmount > 0
        ? ((await depositProvider.getTotalApprovedDeposits(currentAccount.id)) / currentAccount.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentAccount.name),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
          const ThemeToggleButton(iconColor: Colors.white),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: Column(
                children: [
                  // Account summary card
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Account type and goal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getAccountTypeIcon(currentAccount.type),
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  currentAccount.type,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Goal: ZMW ${currentAccount.goalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Progress bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Progress'),
                                Text('${(progressPercentage * 100).toStringAsFixed(1)}%'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: progressPercentage,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Amount collected and members
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Collected',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  'ZMW ${depositProvider.getTotalApprovedDeposits(currentAccount.id).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Members',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  '${currentAccount.members.length}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryColor,
                    tabs: const [
                      Tab(text: 'Deposits'),
                      Tab(text: 'Withdrawals'),
                    ],
                  ),
                  
                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Deposits tab
                        _buildDepositsTab(depositProvider, currentAccount.id),
                        
                        // Withdrawals tab
                        _buildWithdrawalsTab(withdrawalProvider, currentAccount.id),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => _buildBottomSheet(),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDepositsTab(DepositProvider depositProvider, String accountId) {
    return Expanded(
      child: FutureBuilder<List<DepositModel>>(
        future: depositProvider.getAccountDeposits(accountId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final deposits = snapshot.data ?? [];
          if (deposits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No deposits yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Make your first deposit to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToCreateDeposit,
                    icon: const Icon(Icons.add),
                    label: const Text('Make Deposit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deposits.length,
            itemBuilder: (context, index) {
              final deposit = deposits[index];
              return DepositCard(deposit: deposit);
            },
          );
        },
      ),
    );
  }

  Widget _buildWithdrawalsTab(WithdrawalProvider withdrawalProvider, String accountId) {
    return Expanded(
      child: FutureBuilder<List<WithdrawalModel>>(
        future: withdrawalProvider.getAccountWithdrawals(accountId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final withdrawals = snapshot.data ?? [];
          if (withdrawals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.money_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No withdrawals yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a withdrawal request when needed',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToCreateWithdrawal,
                    icon: const Icon(Icons.add),
                    label: const Text('Request Withdrawal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: withdrawals.length,
            itemBuilder: (context, index) {
              final withdrawal = withdrawals[index];
              return WithdrawalCard(withdrawal: withdrawal);
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Choose an action',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_downward,
                color: AppTheme.primaryColor,
              ),
            ),
            title: const Text('Make Deposit'),
            subtitle: const Text('Add funds to this account'),
            onTap: () {
              Navigator.pop(context);
              _navigateToCreateDeposit();
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_upward,
                color: AppTheme.primaryColor,
              ),
            ),
            title: const Text('Request Withdrawal'),
            subtitle: const Text('Withdraw funds from this account'),
            onTap: () {
              Navigator.pop(context);
              _navigateToCreateWithdrawal();
            },
          ),
        ],
      ),
    );
  }

  IconData _getAccountTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'personal':
        return Icons.person;
      case 'group':
        return Icons.group;
      case 'business':
        return Icons.business;
      case 'savings':
        return Icons.savings;
      case 'emergency':
        return Icons.emergency;
      case 'education':
        return Icons.school;
      case 'vacation':
        return Icons.beach_access;
      case 'car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'bike':
        return Icons.pedal_bike;
      default:
        return Icons.account_balance_wallet;
    }
  }
}