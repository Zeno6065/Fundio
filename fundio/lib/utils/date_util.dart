import 'package:intl/intl.dart';

class DateUtil {
  // Format date as 'MMM d, yyyy' (e.g., "Aug 10, 2023")
  static String formatDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }

  // Format date as 'MMM d' (e.g., "Aug 10")
  static String formatShortDate(DateTime date) {
    return DateFormat.MMMd().format(date);
  }

  // Format date as 'MMM d, yyyy h:mm a' (e.g., "Aug 10, 2023 3:30 PM")
  static String formatDateTime(DateTime date) {
    return DateFormat.yMMMMd().add_jm().format(date);
  }

  // Get relative time (e.g., "2 days ago", "Just now")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  // Calculate days remaining until a date
  static int daysRemaining(DateTime date) {
    final now = DateTime.now();
    return date.difference(now).inDays;
  }

  // Check if a date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now);
  }

  // Format date as 'yyyy-MM-dd' (e.g., "2023-08-10")
  static String formatIso(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}