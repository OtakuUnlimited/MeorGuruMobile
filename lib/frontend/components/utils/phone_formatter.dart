String formatAustralianPhone(String phone) {
  if (phone.isEmpty) return '-';

  // remove all non-digits
  String cleaned = phone.replaceAll(RegExp(r'\D'), '');

  // remove leading 0 (local AU format)
  if (cleaned.startsWith('0')) {
    cleaned = cleaned.substring(1);
  }

  // ensure country code
  if (!cleaned.startsWith('61')) {
    cleaned = '61$cleaned';
  }

  // remove country code for formatting
  String number = cleaned.substring(2);

  // pad safely if too short
  while (number.length < 9) {
    number += '0';
  }

  // take only first 9 digits for formatting
  number = number.substring(0, 9);

  String part1 = number.substring(0, 3);
  String part2 = number.substring(3, 6);
  String part3 = number.substring(6, 9);

  return '+61 $part1 $part2 $part3';
}