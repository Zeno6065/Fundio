import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/account_model.dart';
import '../../providers/deposit_provider.dart';
import '../../providers/withdrawal_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/theme_toggle_button.dart';

class CreateWithdrawalScreen extends StatefulWidget {
  final AccountModel account;

  const CreateWithdrawalScreen({Key? key, required this.account}) : super(key: key);

  @override
  State<CreateWithdrawalScreen> createState() => _CreateWithdrawalScreenState();
}

class _CreateWithdrawalScreenState extends State<CreateWithdrawalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _reasonController = TextEditingController();
  String _selectedPaymentMethod = 'Bank Transfer';
  bool _isLoading = false;
  double _availableBalance = 0.0;

  final List<String> _paymentMethods = [
    'Bank Transfer',
    'Mobile Money',
    'Cash',
    'Airtel Money',
    'MTN Money',
    'Zamtel Kwacha',
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableBalance();
  }

  Future<void> _loadAvailableBalance() async {
    final depositProvider = Provider.of<DepositProvider>(context, listen: false);
    final withdrawalProvider = Provider.of<WithdrawalProvider>(context, listen: false);
    
    final totalDeposits = depositProvider.getTotalApprovedDeposits(widget.account.id);
    final totalWithdrawals = withdrawalProvider.getTotalCompletedWithdrawals(widget.account.id);
    
    setState(() {
      _availableBalance = totalDeposits - totalWithdrawals;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _createWithdrawal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final withdrawalProvider = Provider.of<WithdrawalProvider>(context, listen: false);
      final amount = double.parse(_amountController.text.trim());

      await withdrawalProvider.createWithdrawal(
        accountId: widget.account.id,
        amount: amount,
        paymentMethod: _selectedPaymentMethod,
        reason: _reasonController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Withdrawal request created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create withdrawal request: ${e.toString()}')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Withdrawal'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: const [
          ThemeToggleButton(iconColor: Colors.white),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Account info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account: ${widget.account.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Type: ${widget.account.type}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Available Balance: ZMW ${_availableBalance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Amount field
              const Text(
                'Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  hintText: 'Enter amount',
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: 'ZMW ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  // First validate that it's a valid amount
                  final amountError = Validators.validateAmount(value);
                  if (amountError != null) {
                    return amountError;
                  }
                  
                  // Then validate that it doesn't exceed available balance
                  final amount = double.tryParse(value ?? '') ?? 0;
                  if (amount > _availableBalance) {
                    return 'Amount exceeds available balance';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Payment method field
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: _paymentMethods.map((method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Reason field
              const Text(
                'Reason (Optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  hintText: 'Enter reason for withdrawal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 40),
              
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createWithdrawal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Request Withdrawal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Note about withdrawal approval
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.amber[800],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your withdrawal request will be pending until approved by an account admin.',
                        style: TextStyle(
                          color: Colors.amber[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}