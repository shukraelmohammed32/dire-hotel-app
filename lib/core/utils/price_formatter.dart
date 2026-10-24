String formatEtb(int amount) {
  final value = amount.toString();
  if (value.length <= 3) return value;

  final chars = value.split('').reversed.toList();
  final buffer = StringBuffer();
  for (var i = 0; i < chars.length; i++) {
    if (i > 0 && i % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(chars[i]);
  }
  return buffer.toString().split('').reversed.join();
}
