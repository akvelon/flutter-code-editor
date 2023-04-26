import 'package:equatable/equatable.dart';

class SearchSettings extends Equatable {
  const SearchSettings({
    required this.isCaseSensitive,
    required this.isRegExp,
    required this.pattern,
  });

  final bool isCaseSensitive;
  final bool isRegExp;
  final String pattern;

  static const empty = SearchSettings(
    isCaseSensitive: false,
    isRegExp: false,
    pattern: '',
  );

  SearchSettings copyWith({
    bool? isCaseSensitive,
    bool? isRegExp,
    String? pattern,
  }) {
    return SearchSettings(
      isCaseSensitive: isCaseSensitive ?? this.isCaseSensitive,
      isRegExp: isRegExp ?? this.isRegExp,
      pattern: pattern ?? this.pattern,
    );
  }

  @override
  List<Object?> get props => [isCaseSensitive, isRegExp, pattern];
}
