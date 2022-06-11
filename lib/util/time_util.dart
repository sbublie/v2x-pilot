import 'package:intl/intl.dart';

/// Returns HH:mm:ss formatted string converted from intersection [timestamp].
///
/// [timestamp] is in seconds from current hour.
String getLabelFromTimestamp(timestamp) {
  if (timestamp == null) {
    return "No data";
  }

  DateTime convertedTs = convertIntersectionTime(timestamp);
  return DateFormat('HH:mm:ss').format(convertedTs.toLocal());
}

/// Returns the difference of the current time and the given intersection [timestamp] in seconds.
///
/// [timestamp] is in seconds from current hour.
int getRemainingTime(int timestamp) {
  DateTime convertedTs = convertIntersectionTime(timestamp);
  return convertedTs.difference(DateTime.now().toUtc()).inSeconds;
}

/// Converts the intersection [timestamp] to a unix DateTime.
///
/// [timestamp] is in seconds from current hour.
DateTime convertIntersectionTime(int timestamp) {
  // Correct timetamp precision
  double seconds = timestamp / 10;

  // Get current hour timestamp and add timestamp from intersection to it.
  // TODO: Handle edge cases
  DateTime now = DateTime.now().toUtc();
  DateTime time = DateTime.utc(now.year, now.month, now.day, now.hour);
  DateTime timeAdded = time.add(Duration(seconds: seconds.round()));

  return timeAdded;
}
