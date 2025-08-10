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
      return 'Username is required';
    }
    
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Basic phone validation - allows digits, spaces, dashes, parentheses, and plus sign
    final phoneRegex = RegExp(r'^[\+]?[0-9\s\-\(\)]{10,}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
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

  // Required field validation (alias for validateRequired)
  static String? required(String? value, String fieldName) {
    return validateRequired(value, fieldName);
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

  // Compose multiple validators
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  // Number validation
  static String? number(String? value, [String? errorMessage]) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Value is required';
    }
    
    if (double.tryParse(value) == null) {
      return errorMessage ?? 'Please enter a valid number';
    }
    
    return null;
  }

  // Minimum value validation
  static String? min(double minValue, String? value, [String? errorMessage]) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'Value is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return errorMessage ?? 'Please enter a valid number';
    }
    
    if (number < minValue) {
      return errorMessage ?? 'Value must be at least $minValue';
    }
    
    return null;
  }
}