import 'package:highlight/highlight.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/scala.dart';

class SingleLineComments {
  const SingleLineComments._();

  static final byMode = <Mode, List<String>>{
    java: [_slashes],
    dart: [_slashes],
    go: [_slashes],
    scala: [_slashes],
    python: [_hash],
  };

  static const _slashes = '//';
  static const _hash = '#';
}
