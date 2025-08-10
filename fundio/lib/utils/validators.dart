import 'package:flutter/material.dart';

class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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

  // Simple required validator used as `validator: Validators.validateRequired`
  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  // Username validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  // Phone validation (very simple)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    final digits = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.length < 7) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // Convenience factory used as `Validators.required('Message')`
  static FormFieldValidator<String> required(String message) {
    return (value) {
      if (value == null || value.isEmpty) return message;
      return null;
    };
  }

  // Compose multiple validators
  static FormFieldValidator<String> compose(List<FormFieldValidator<String>> validators) {
    return (value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }

  // Number validator
  static FormFieldValidator<String> number(String message) {
    return (value) {
      if (value == null || value.isEmpty) return message;
      return double.tryParse(value) == null ? message : null;
    };
  }

  // Minimum value validator
  static FormFieldValidator<String> min(num minValue, String message) {
    return (value) {
      final parsed = double.tryParse(value ?? '');
      if (parsed == null || parsed < minValue) return message;
      return null;
    };
  }
}