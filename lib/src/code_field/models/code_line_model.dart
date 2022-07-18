class CodeLineModel {
  final String text;
  final int lineNumber;
  final int startIndex;
  final int endIndex;
  final bool isReadOnly;

  CodeLineModel({
    required this.text,
    required this.lineNumber,
    required this.startIndex,
    required this.endIndex,
    required this.isReadOnly,
  });

  @override
  String toString() =>
      'Line №$lineNumber, ReadOnly = $isReadOnly, StartIndex = $startIndex, EndIndex = $endIndex, Text: $text';
}
