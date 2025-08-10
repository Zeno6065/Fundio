import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/withdrawal_model.dart';
import '../providers/app_provider.dart';
import '../providers/withdrawal_provider.dart';

class WithdrawalCard extends StatelessWidget {
  final Withdrawal withdrawal;

  const WithdrawalCard({Key? key, required this.withdrawal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final withdrawalProvider = Provider.of<WithdrawalProvider>(context);
    final isAdmin = appProvider.isUserAdmin(withdrawal.accountId);
    final dateFormat = DateFormat('MMM d, yyyy');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Amount and payment method
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ZMW ${withdrawal.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      withdrawal.paymentMethod,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                
                // Status indicator
                _buildStatusChip(withdrawal.status),
              ],
            ),
            const SizedBox(height: 16),
            
            // Date and user info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      withdrawal.userName.isNotEmpty ? withdrawal.userName : 'Anonymous',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(withdrawal.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Reason for withdrawal
            if (withdrawal.reason.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reason:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      withdrawal.reason,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Admin actions for pending withdrawals
            if (isAdmin && withdrawal.status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => _rejectWithdrawal(context, withdrawalProvider),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => _approveWithdrawal(context, withdrawalProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Approve'),
                    ),
                  ],
                ),
              ),
              
            // Admin actions for approved withdrawals
            if (isAdmin && withdrawal.status == 'approved')
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => _completeWithdrawal(context, withdrawalProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Mark as Completed'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;
    
    switch (status.toLowerCase()) {
      case 'approved':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        iconData = Icons.check_circle_outline;
        break;
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        iconData = Icons.done_all;
        break;
      case 'rejected':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        iconData = Icons.cancel_outlined;
        break;
      case 'pending':
      default:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        iconData = Icons.access_time;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: 16,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            status.capitalize(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveWithdrawal(BuildContext context, WithdrawalProvider withdrawalProvider) async {
    try {
      await withdrawalProvider.approveWithdrawal(withdrawal.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal approved successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve withdrawal: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _rejectWithdrawal(BuildContext context, WithdrawalProvider withdrawalProvider) async {
    try {
      await withdrawalProvider.rejectWithdrawal(withdrawal.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal rejected')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject withdrawal: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _completeWithdrawal(BuildContext context, WithdrawalProvider withdrawalProvider) async {
    try {
      await withdrawalProvider.completeWithdrawal(withdrawal.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal marked as completed')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete withdrawal: ${e.toString()}')),
        );
      }
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}