import 'dart:async';

import 'package:meta/meta.dart';

import '../../../flutter_code_editor.dart';

abstract class Analyzer {
  Analyzer();

  final StreamController<Code> _codeStream = StreamController();
  final StreamController<List<Issue>> _issueStream =
      StreamController.broadcast();

  void init({
    Code? code,
    void Function(List<Issue> issues)? listener,
  }) {
    _codeStream.stream.listen(
      onCodeChanged,
      onError: (e) {
        // ignored
      },
    );

    if (listener != null) {
      addListener(listener);
    }

    if (code != null) {
      emit(code);
    }
  }

  Future<void> onCodeChanged(Code code) async {
    await analyze(code).then(_issueStream.add);
  }

  void emit(Code event) {
    _codeStream.add(event);
  }

  void addListener(void Function(List<Issue> issue) callback) {
    _issueStream.stream.listen(callback);
  }

  Future<List<Issue>> analyze(Code code);

  @mustCallSuper
  void dispose() {
    _codeStream.close();
    _issueStream.close();
  }
}
