import 'dart:async';

import 'package:meta/meta.dart';

import '../../../flutter_code_editor.dart';
import '../api/models/issue.dart';

abstract class Analyzer {
  Analyzer() {
    codeStream.stream.listen(
      onCodeChanged,
      onError: (e) {
        // ignored
      },
    );
  }

  @internal
  final StreamController<Code> codeStream = StreamController();
  final StreamController<List<Issue>> _issueStream = StreamController();

  Future<void> onCodeChanged(Code code) async {
    await analyze(code).then(_issueStream.add);
  }

  void addListener(void Function(List<Issue> issue) callback) {
    _issueStream.stream.listen(callback);
  }

  Future<List<Issue>> analyze(Code code);

  @mustCallSuper
  void dispose() {
    codeStream.close();
    _issueStream.close();
  }
}
