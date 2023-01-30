import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../flutter_code_editor.dart';
import '../../job_runner/job_runner.dart';

abstract class Analyzer {
  Analyzer();

  final StreamController<Code> _codeStream = StreamController();
  final StreamController<List<Issue>> _issueStream =
      StreamController.broadcast();
  final _jobRunner = JobRunner();

  void init({
    required Code Function() getCode,
    void Function(List<Issue> issues)? listener,
  }) {
    if (listener != null) {
      addListener(listener);
    }

    _codeStream.stream.listen(
      onCodeChanged,
      onError: (e) {
        // ignored
      },
    );

    _jobRunner.runJob(
      () {
        emit(getCode());
      },
      const Duration(seconds: 1),
    );
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
    unawaited(_codeStream.close());
    unawaited(_issueStream.close());
  }
}
