import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_theme.dart';
import '../../providers/account_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/theme_toggle_button.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  
  String _selectedCurrency = 'ZMW';
  String _selectedType = 'savings';
  DateTime _maturityDate = DateTime.now().add(const Duration(days: 365));
  bool _allowEarlyWithdrawal = false;
  bool _isLoading = false;

  final List<String> _accountTypes = [
    'savings',
    'investment',
    'emergency',
    'education',
    'travel',
    'housing',
    'vehicle',
    'other'
  ];

  final List<String> _currencies = ['ZMW', 'USD', 'EUR', 'GBP'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _maturityDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _maturityDate) {
      setState(() {
        _maturityDate = picked;
      });
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      
      // Create withdrawal rules
      final withdrawalRules = {
        'allowEarlyWithdrawal': _allowEarlyWithdrawal,
        'penaltyPercentage': _allowEarlyWithdrawal ? 5.0 : 0.0,
        'type': _selectedType,
      };

      // Create account
      await accountProvider.createAccount(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        currency: _selectedCurrency,
        targetAmount: double.parse(_targetAmountController.text.trim()),
        maturityDate: _maturityDate,
        withdrawalRules: withdrawalRules,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create account: ${e.toString()}')),
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
        title: const Text('Create Account'),
        backgroundColor: AppTheme.primaryColor,
        actions: const [
          ThemeToggleButton(iconColor: Colors.white),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Type
                    const Text(
                      'Account Type',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: _accountTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type.substring(0, 1).toUpperCase() + type.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Account Name
                    const Text(
                      'Account Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter account name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: Validators.required('Account name is required'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    const Text(
                      'Description',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'Enter account description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      maxLines: 3,
                      validator: Validators.required('Description is required'),
                    ),
                    const SizedBox(height: 16),
                    
                    // Target Amount and Currency
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Target Amount
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Target Amount',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _targetAmountController,
                                decoration: InputDecoration(
                                  hintText: 'Enter target amount',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: Validators.compose([
                                  Validators.required('Target amount is required'),
                                  Validators.number('Please enter a valid number'),
                                  Validators.min(1, 'Amount must be greater than 0'),
                                ]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Currency
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Currency',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedCurrency,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                items: _currencies.map((currency) {
                                  return DropdownMenuItem<String>(
                                    value: currency,
                                    child: Text(currency),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCurrency = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Maturity Date
                    const Text(
                      'Maturity Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(_maturityDate),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Withdrawal Rules
                    const Text(
                      'Withdrawal Rules',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Allow Early Withdrawal'),
                      subtitle: Text(
                        _allowEarlyWithdrawal
                            ? 'Early withdrawals will incur a 5% penalty'
                            : 'Withdrawals only allowed at maturity date',
                      ),
                      value: _allowEarlyWithdrawal,
                      onChanged: (value) {
                        setState(() {
                          _allowEarlyWithdrawal = value;
                        });
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                    const SizedBox(height: 24),
                    
                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}