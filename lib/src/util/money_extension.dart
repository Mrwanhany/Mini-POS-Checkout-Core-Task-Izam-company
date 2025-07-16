/// Extension on [num] to format numbers as money strings
extension MoneyExtension on num {
  /// Formats this number as a money string with 2 decimal places
  ///
  /// Example:
  /// ```dart
  /// 12.34.asMoney // "12.34"
  /// 12.asMoney    // "12.00"
  /// ```
  String get asMoney => toStringAsFixed(2);
}
