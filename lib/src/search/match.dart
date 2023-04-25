import 'package:equatable/equatable.dart';

class SearchMatch extends Equatable {
  const SearchMatch({
    required this.start,
    required this.end,
  });

  final int start;
  final int end;

  @override
  List<Object?> get props => [start, end];
}
