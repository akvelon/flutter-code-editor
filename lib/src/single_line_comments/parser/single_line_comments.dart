import 'package:highlight/highlight_core.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/php.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/scala.dart';

class SingleLineComments {
  const SingleLineComments._();

  static final byMode = <Mode, List<String>>{
    dart: [_slashes],
    go: [_slashes],
    java: [_slashes],
    php: [_slashes, _hash],
    python: [_hash],
    scala: [_slashes],
  };

  static const _slashes = '//';
  static const _hash = '#';
}
