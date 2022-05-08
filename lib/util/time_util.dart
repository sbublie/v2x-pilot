import 'package:intl/intl.dart';

/// Convert intersection timestamp to date string
String getLabelFromTimestamp(timestamp) {
  if (timestamp == null) {
    return "No data";
  }
  DateTime date =
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
          .add(const Duration(hours: 1));
  return DateFormat('HH:mm:ss').format(date);
}

/// Calculate the remaining time from timestamp
int getRemainingTime(int timestamp) {
  return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
      .subtract(const Duration(hours: 1))
      .difference(DateTime.now())
      .inSeconds;
}
