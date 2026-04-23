extension StringExtensions on String {
  String get sentenceCase {
    if (isEmpty) return this;
    return '\${this[0].toUpperCase()}\${substring(1)}';
  }
}
