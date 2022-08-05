import 'package:meta/meta.dart';

@immutable
class NamedSection {
  /// Zero-based index of the line with the starting tag.
  final int startLine;

  /// Zero-based index of the line with the ending tag.
  final int endLine;

  final String name;

  const NamedSection({
    required this.startLine,
    required this.endLine,
    required this.name,
  });

  @override
  int get hashCode => Object.hash(startLine, endLine, name);

  @override
  bool operator ==(Object other) {
    return other is NamedSection &&
        startLine == other.startLine &&
        endLine == other.endLine &&
        name == other.name;
  }

  @override
  String toString() => '$startLine-$endLine: "$name"';
}
