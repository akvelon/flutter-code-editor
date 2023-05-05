import 'js_workarounds_stub.dart'
    if (dart.library.js) 'js_workarounds_web.dart';

void disableSpellCheckIfWeb() {
  disableSpellCheck();
}

void disableBuiltInSearchIfWeb() {
  disableBuiltInSearch();
}
