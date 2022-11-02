import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';

import '../code/code.dart';

class CodeHistoryRecord with EquatableMixin {
  final Code code;
  final TextSelection selection;

  const CodeHistoryRecord({
    required this.code,
    required this.selection,
  });

  @override
  List<Object> get props => [
        code,
        selection,
      ];
}
