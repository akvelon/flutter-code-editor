import 'disable_spell_check_if_web_stub.dart'
    if (dart.library.js) 'disable_spell_check_if_web.dart';

void disableSpellCheckIfWeb() {
  disableSpellCheck();
}
