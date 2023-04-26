import 'package:equatable/equatable.dart';

class SearchSettings extends Equatable {
  const SearchSettings({
    required this.isCaseSensitive,
    required this.isRegExp,
    required this.pattern,
    required this.isEnabled,
  });

  final bool isCaseSensitive;
  final bool isRegExp;
  final String pattern;
  final bool isEnabled;

  static const empty = SearchSettings(
    isCaseSensitive: false,
    isEnabled: false,
    isRegExp: false,
    pattern: '',
  );

  SearchSettings copyWith({
    bool? isCaseSensitive,
    bool? isEnabled,
    bool? isRegExp,
    String? pattern,
  }) {
    return SearchSettings(
      isCaseSensitive: isCaseSensitive ?? this.isCaseSensitive,
      isEnabled: isEnabled ?? this.isEnabled,
      isRegExp: isRegExp ?? this.isRegExp,
      pattern: pattern ?? this.pattern,
    );
  }

  @override
  List<Object?> get props => [
        isCaseSensitive,
        isEnabled,
        isRegExp,
        pattern,
      ];
}
