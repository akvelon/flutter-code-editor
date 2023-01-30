import 'dart:async';

import 'package:flutter/material.dart';

/// Runs jobs in background.
///
/// Must be used in synchronous context.
class JobRunner {
  final List<Timer> _timers = [];

  int runJob(VoidCallback callback, Duration interval) {
    final timer = Timer.periodic(interval, (timer) {
      callback.call();
    });

    final id = _timers.length;
    _timers.add(timer);

    return id;
  }

  void cancelJobAt(int index) {
    _timers[index].cancel();
  }

  @mustCallSuper
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
  }
}
