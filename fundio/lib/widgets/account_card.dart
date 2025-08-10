import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/account_model.dart';
import '../providers/deposit_provider.dart';
import '../constants/app_theme.dart';
import '../utils/currency_util.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback onTap;

  const AccountCard({
    Key? key,
    required this.account,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final depositProvider = Provider.of<DepositProvider>(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account name and icon
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForAccountType('savings'),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      account.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Goal amount
              Row(
                children: [
                  const Text(
                    'Goal: ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    CurrencyUtil.format(account.targetAmount, account.currency),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Members count
              Text(
                '${account.members.length} members',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress area
              FutureBuilder<double>(
                future: depositProvider.getTotalApprovedDeposits(account.id),
                builder: (context, snapshot) {
                  final total = snapshot.data ?? 0.0;
                  final progress = account.targetAmount > 0
                      ? (total / account.targetAmount).clamp(0.0, 1.0)
                      : 0.0;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyUtil.format(total, account.currency),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForAccountType(String type) {
    switch (type.toLowerCase()) {
      case 'savings':
        return Icons.savings_outlined;
      case 'investment':
        return Icons.trending_up;
      case 'emergency':
        return Icons.health_and_safety_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'travel':
        return Icons.flight_outlined;
      case 'housing':
        return Icons.home_outlined;
      case 'vehicle':
        return Icons.directions_car_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}