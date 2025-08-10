class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  // Username validation
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  // Amount validation
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    
    final amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    
    if (!amountRegex.hasMatch(value)) {
      return 'Please enter a valid amount';
    }
    
    final amount = double.tryParse(value);
    
    if (amount == null || amount <= 0) {
      return 'Amount must be greater than zero';
    }
    
    return null;
  }

  // Date validation
  static String? validateDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    
    return null;
  }

  // Future date validation
  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    
    final now = DateTime.now();
    
    if (value.isBefore(now)) {
      return 'Date must be in the future';
    }
    
    return null;
  }
}