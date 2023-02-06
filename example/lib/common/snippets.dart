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
    System.out.println("Factorial of " + num + " is " + factorial(num));
  }// [END section1]
}
''';

const dartSnippet = r'''
/// Calculates the factorial of the number.
/// The number must be >= 0.
int factorial(int n){
  if(n == 0){
    return 0;
  }

  return n * factorial(n - 1);
}

void main(){
  int num = 5;
  print('Factorial of $num is  ${factorial(num)}');
}
''';
