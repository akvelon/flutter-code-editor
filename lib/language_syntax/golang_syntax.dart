/* Search for syntax errors for java and dart : for loop errors
 Including comments, strings. */

Map<int, String> findGolangErrors(String text) {
  List<String> lines = text.split('\n');
  Map<int, String> errors = <int, String>{};

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim().isEmpty || lines[i].startsWith(RegExp('\\s*//'))) {
      continue;
    }

    if (lines[i].startsWith(RegExp('\\s*/\\*'))) {
      while ((!lines[i].contains(RegExp('\\*/\\s*'))) && (i < lines.length - 1)) {
        i++;
      }
    } 
    else if (lines[i].startsWith(RegExp('.*`'))) {
      do {
        i++;
      } while ((!lines[i].contains(RegExp('`'))) && (i < lines.length - 1));
    }
    
    // error in for construct
    if (lines[i].contains(RegExp('\\s*for\\s+')) &&
        (!lines[i].contains(RegExp("[\"']\\s*for\\s+[\"']"))) &&
        (!lines[i].contains(RegExp('//\\s*for\\s+')))) {
      String commandFor = '';
      while ((!lines[i].contains(RegExp('{')) ||
              (lines[i].contains(RegExp("[\"'].*{.*[\"']"))) ||
              (lines[i].contains(RegExp('//.*{')))) &&
          (i < lines.length - 1)) {
        commandFor += lines[i];
        i++;
        lines[i] = lines[i];
      }
      commandFor += lines[i];
      if (commandFor.contains(RegExp('for.*:=')) && commandFor.contains(RegExp('for.*[\+-][\+-]'))) {
        if (!commandFor.contains(RegExp('for.*:=.*;.*;.*[\+-][\+-]'))){
          errors.addAll(<int, String>{(i + 1): 'Incorrect for statement'});
        }
      }
    }
  }
  return errors;
}
