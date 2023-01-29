import '../../code/code.dart';

import '../api/analyzer.dart';
import '../api/models/issue.dart';

class DefaultAnalyzer extends Analyzer {
  @override
  Future<List<Issue>> analyze(Code code) async {
    return code.invalidBlocks.map((e) => e.issue).toList(
          growable: false,
        );
  }
}
