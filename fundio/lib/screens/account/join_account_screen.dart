import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/account_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/theme_toggle_button.dart';

class JoinAccountScreen extends StatefulWidget {
  const JoinAccountScreen({Key? key}) : super(key: key);

  @override
  State<JoinAccountScreen> createState() => _JoinAccountScreenState();
}

class _JoinAccountScreenState extends State<JoinAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final accountProvider = Provider.of<AccountProvider>(context, listen: false);
      await accountProvider.acceptInvite(_inviteCodeController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully joined account!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join account: ${e.toString()}')),
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
        title: const Text('Join Account'),
        backgroundColor: AppTheme.primaryColor,
        actions: const [
          ThemeToggleButton(iconColor: Colors.white),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Illustration
                    Center(
                      child: Image.asset(
                        'assets/images/join_account.png',
                        height: 200,
                        fit: BoxFit.contain,
                        // If the asset doesn't exist, use a placeholder icon
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.group_add,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title and description
                    const Text(
                      'Join an Existing Account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter the invite code shared with you to join an existing account.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Invite code field
                    const Text(
                      'Invite Code',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _inviteCodeController,
                      decoration: InputDecoration(
                        hintText: 'Enter invite code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: Validators.required('Invite code is required'),
                    ),
                    const SizedBox(height: 32),
                    
                    // Join button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _joinAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Join Account',
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