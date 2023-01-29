import '../api/analyzer.dart';
import '../api/models/issue.dart';

class DefaultAnalyzer extends Analyzer {
  @override
  Future<List<Issue>> analyze(String code) {
    throw UnimplementedError();
  }

}