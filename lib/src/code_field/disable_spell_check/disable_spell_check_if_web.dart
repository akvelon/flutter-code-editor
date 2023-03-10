// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

import 'package:flutter/foundation.dart';

const _jsSetDisableSpellCheckTimer = '''
var disableSpellCheck = setInterval(function () {
      var elements = document.getElementsByTagName('flt-glass-pane');
      for (let child of elements[0].shadowRoot.children) {
        if (child.tagName.toLowerCase() == 'form') {
          let textFields = child.getElementsByTagName('textarea');
          for (let textField of textFields) {
            textField.setAttribute('spellcheck', 'false');
          }
        }
      }
    }, 1000);
''';

bool _isTimerSet = false;

void disableSpellCheck() {
  if (kIsWeb) {
    if (!_isTimerSet) {
      js.context.callMethod('eval', [_jsSetDisableSpellCheckTimer]);
      _isTimerSet = true;
    }
  }
}
