import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../flutter_code_editor.dart';
import '../../job_runner/job_runner.dart';

/// Service for analzying the code inside CodeField.
///
/// Uses streams to connect incoming new code and outgoing list of issues.
/// Retrieves code from `CodeController` every second and adds to the stream for analysis.
/// You can listen to the stream of issues to perform some action when issues are updated.
///
/// Inherit and implement [analyze] method to use in [CodeController].
abstract class Analyzer {
  Analyzer();

  final StreamController<Code> _codeStream = StreamController();
  final StreamController<List<Issue>> _issueStream =
      StreamController.broadcast();
  final _jobRunner = JobRunner();

  /// Initializes the analyzer.
  ///
  /// [getCode] is a getter function used to retrieve code periodically.
  /// [listener] is a listener function to the stream of issues.
  void init({
    required Code Function() getCode,
    void Function(List<Issue> issues)? listener,
  }) {
    if (listener != null) {
      addListener(listener);
    }

    _codeStream.stream.listen(
      _onCodeChanged,
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

  Future<void> _onCodeChanged(Code code) async {
    await analyze(code).then(_issueStream.add);
  }

  /// To emit a single event to the stream.
  void emit(Code event) {
    _codeStream.add(event);
  }

  /// Listen to the issues stream.
  void addListener(void Function(List<Issue> issue) callback) {
    _issueStream.stream.listen(callback);
  }

  /// Analyzes the code and generates new list of issues.
  Future<List<Issue>> analyze(Code code);

  @mustCallSuper
  void dispose() {
    unawaited(_codeStream.close());
    unawaited(_issueStream.close());
    _jobRunner.dispose();
  }
}
