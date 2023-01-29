const javaFactorialSnippet = '''
class MyClass {
  /// Calculates the factorial of the number.
  /// The number must be >= 0.
  static int factorial(int n) {
    if (n == 0) {
      return 1;
    }

    return n * factorial(n - 1);
  }

  public static void main(String[] args) {
    int num = 5;
    System.out.println("Factorial of " + num + " is " + factorial(5));
  }
}
''';

const javaFactorialSectionsSnippet = '''
class MyClass {
  /// Calculates the factorial of the number.
  /// The number must be >= 0.
  static int factorial(int n) {
    if (n == 0) {
      return 1;
    }

    return n * factorial(n - 1);
  }

  public static void main(String[] args) {// [START section1]
    int num = 5;
    System.out.println("Factorial of " + num + " is " + factorial(5));
  }// [END section1]
}
''';

const dartSnippet = '''
import 'package:flutter/painting.dart';

extension TextStyleExtension on TextStyle {
  String toMapString() {
    final result = {
      'color': color,
      //add another fields if required
    };
    result.removeWhere((key, value) => value == null);
    return result.toString();
  }

  TextStyle paled() {
    final clr = color;

    if (clr == null) {
      return this;
    }

    return copyWith(
      color: Color.fromARGB(
        clr.alpha ~/ 2,
        clr.red,
        clr.green,
        clr.blue,
      ),
    );
  }
}
''';
