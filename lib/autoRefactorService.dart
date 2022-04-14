import 'dart:math';
import 'dart:convert';

import 'package:tuple/tuple.dart';

import 'constants/constants.dart';


String autoRefactor(String text, String language, String refactorSettings){
  String refactorText = "";
  Map<String, dynamic> settings = jsonDecode(refactorSettings);
  List<Tuple2<String, List<Tuple2<int, int>>>> indexes;
  Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> result = removeExtraSpacesAndLines(text, 
                                                                      language, int.parse(settings['max_extra_lines']));
  refactorText = result.item1;
  indexes = result.item2;
  refactorText = refactorText.trimRight();
  final List<String> textInLines = refactorText.split('\n');
  result = addLineBreakAfterBracket(textInLines, '', settings['linebreak_after_this_brackets'], 
                                                                      ''.padRight(int.parse(settings['intend']), ' '), indexes);
  refactorText = result.item1;
  indexes = result.item2;                                                                    
  if (language == python) { 
    refactorText = addLineBreakAfterFunctionColon(refactorText, ''.padRight(int.parse(settings['intend'])), indexes);
  }
  refactorText = refactorText.trimRight();
  if (settings['add_line_at_the_end'] == "true"){
    refactorText += '\n ';
  }
  return refactorText;
}

Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> removeExtraSpacesAndLines(String text, String language, 
                                                                  int maxExtraLines){
  List<Tuple2<String, List<Tuple2<int, int>>>> indexes = [];
  String refactorText = "";
  text = text.trim();
  final List<String> textInLines = text.split('\n');
  final pattern = RegExp('\\s\\s+');
  bool multiline = false;
  String multilineQuotes = '';
  for (int i = 0; i < textInLines.length; i++) {
    if (textInLines[i] == '' || textInLines[i].trim() == '') {
      if (multiline) {
        refactorText += '\n';
        indexes.add(Tuple2(multline, []));
      }
      else {
        final List<String> reTextInLines = refactorText.split('\n');
        if (reTextInLines.length >= maxExtraLines){
          for (int j = 0; j < maxExtraLines; j++){
            if (reTextInLines[reTextInLines.length - 2 - j] != ''){
              refactorText += '\n';
              indexes.add(Tuple2(simple, []));
              break;
            }
          }
        }
        else {
          refactorText += '\n';
          indexes.add(Tuple2(simple, []));
        }
      }
    }
    else {
      String mutableString = textInLines[i];
      List<Tuple2<int, int>> indexesOfline = [];
      int beforeIndex = 0;
      while (mutableString.length > 0){
        List<String> symbols = [];
        List<int> firstIndexesOfSymbols = [];

        if (language == go){
          int indexMultiLineGo = mutableString.indexOf('`');
          symbols.add('`');
          firstIndexesOfSymbols.add(indexMultiLineGo);
        }
        else {
          int indexDoubMultiQuote = mutableString.indexOf('"""');
          int indexSingleMultiQuote = mutableString.indexOf('\'\'\'');
          symbols.addAll(['"""', '\'\'\'']);
          firstIndexesOfSymbols.addAll([indexDoubMultiQuote, indexSingleMultiQuote]);
        }
        
        if (language == python){
          int indexOfHash = mutableString.indexOf('#');
          symbols.add('#');
          firstIndexesOfSymbols.add(indexOfHash);
        }
        else {
          int indexOfSlashes = mutableString.indexOf('//');
          int startIndex = mutableString.indexOf('/*');
          int endIndex = mutableString.indexOf('*/');
          symbols.addAll(['//', '/*', '*/']);
          firstIndexesOfSymbols.addAll([indexOfSlashes, startIndex, endIndex]);
        }

        RegExp singleQuoteRex1 = RegExp(r"[^\\]'");
        RegExp singleQuoteRex2 = RegExp(r"^'");
        RegExp doubleQuoteRex1 = RegExp(r'[^\\]"');
        RegExp doubleQuoteRex2 = RegExp(r'^"');

        int indexDoubleQuote1 = mutableString.indexOf(doubleQuoteRex1);
        int indexDoubleQuote2 = mutableString.indexOf(doubleQuoteRex2);
        int indexDoubQuote = indexDoubleQuote2 == -1 ? (indexDoubleQuote1 == -1 ? -1 : indexDoubleQuote1 + 1) : indexDoubleQuote2;

        int indexSingleQuote1 = mutableString.indexOf(singleQuoteRex1);
        int indexSingleQuote2 = mutableString.indexOf(singleQuoteRex2);
        int indexSingleQuote = indexSingleQuote2 == -1 ? (indexSingleQuote1 == -1 ? -1 : indexSingleQuote1 + 1) : indexSingleQuote2;

        symbols.addAll(['\'', '"']);
        firstIndexesOfSymbols.addAll([indexSingleQuote, indexDoubQuote]);

        int minIndexOfSymbols = firstIndexesOfSymbols.reduce(max);
        if (minIndexOfSymbols == -1){
          if (multiline){
            refactorText += mutableString;
            indexes.add(Tuple2(multline, []));
            mutableString = '';
          }
          else {
            refactorText += mutableString.replaceAll(pattern, ' ').trimLeft();
            mutableString = '';
          }
        }
        else {
          int indexOfmin = firstIndexesOfSymbols.indexOf(minIndexOfSymbols);
          for (int i = 0; i < firstIndexesOfSymbols.length; i++){
            if (firstIndexesOfSymbols[i] < minIndexOfSymbols && firstIndexesOfSymbols[i] != -1){
              minIndexOfSymbols = firstIndexesOfSymbols[i];
              indexOfmin = i;
            }
          }
          String symbol = symbols[indexOfmin];
          String beforeSymbol;
          if (!multiline) {
            beforeSymbol = mutableString.substring(0, 
                                        firstIndexesOfSymbols[indexOfmin] + symbol.length).replaceAll(pattern, ' ').trimLeft();
          }
          else {
            beforeSymbol = mutableString.substring(0, firstIndexesOfSymbols[indexOfmin] + symbol.length);
          }
          refactorText += beforeSymbol;
          mutableString =  mutableString.replaceRange(0, firstIndexesOfSymbols[indexOfmin] + symbol.length, '');
          beforeIndex += beforeSymbol.length;

          if (symbol == '#' || symbol == '//'){
            if (multiline){
              indexesOfline.add(Tuple2(0, beforeIndex - 1));
            }
            else {
              refactorText += mutableString;
              indexesOfline.add(Tuple2(beforeIndex, beforeIndex + mutableString.length - 1));
              mutableString = "";
            }
          }
          else if (symbol == '"""' || symbol == "'''" || symbol == '`' || symbol == '/*' || symbol == '*/'){
            if (multiline){
              if (multilineQuotes == symbol){
                indexesOfline.add(Tuple2(0, beforeIndex - 1));
                multiline = false;
              }
              else {
                indexesOfline.add(Tuple2(0, beforeIndex - 1));
              }
            }
            else {
              int secondIndex = mutableString.indexOf(symbol == '/*' ? '*/' : symbol);
              if (secondIndex == -1){
                refactorText += mutableString;
                indexesOfline.add(Tuple2(beforeIndex, beforeIndex + mutableString.length - 1));
                mutableString = "";
                multilineQuotes = symbol == '/*' ? '*/' : symbol;
                multiline = true;
              }
              else{
                String inQuotes = mutableString.substring(0, secondIndex + symbol.length);
                indexesOfline.add(Tuple2(beforeIndex, beforeIndex + inQuotes.length - 1));
                beforeIndex += inQuotes.length;
                refactorText += inQuotes;
                mutableString =  mutableString.replaceRange(0, secondIndex + symbol.length, '');
              }
            }
          }
          else if (symbol == '"' || symbol == '\''){
            if (multiline){
              indexesOfline.add(Tuple2(0, beforeIndex));
            }
            else {
              int secondIndex1 = mutableString.indexOf(symbol == '"' ? doubleQuoteRex1 : singleQuoteRex1);
              int secondIndex2 = mutableString.indexOf(symbol == '"' ? doubleQuoteRex2 : singleQuoteRex2);
              int secondIndex = secondIndex2 == -1 ? (secondIndex1 == -1 ? -1 : secondIndex1 + 1) : secondIndex2;
              if (secondIndex == -1){
                refactorText += mutableString;
              }
              else {
                String inQuotes = mutableString.substring(0, secondIndex + symbol.length);
                indexesOfline.add(Tuple2(beforeIndex, beforeIndex + inQuotes.length - 1));
                beforeIndex += inQuotes.length;
                refactorText += inQuotes;
                mutableString =  mutableString.replaceRange(0, secondIndex + symbol.length, '');
              }
            }
          }
        }
      }
      refactorText += '\n';
      if (indexes.length - 1 != i){
        indexes.add(Tuple2(haveString, indexesOfline));
      }
    }
  }
  return Tuple2(refactorText, indexes);
}

Tuple2<bool, int> symbolContains(String bracket, String text, Tuple2<String, List<Tuple2<int, int>>> indexesOfString){
  if (indexesOfString.item1 == multline){
    return Tuple2(false, -1);
  }
  if (!text.contains(bracket)){
    return Tuple2(false, -1);
  }
  if (indexesOfString.item1 == simple){
    return Tuple2(true, text.indexOf(bracket));
  }
  List<int> indexesOfBracket= [];
  int index = 0;
  while(index != -1){
    index = text.indexOf(bracket, index);
    if (index != -1){
      indexesOfBracket.add(index);
      index +=1;
    }
  }
  for (int i = 0; i < indexesOfBracket.length; i++){
    bool insideString = false;
    for (int j = 0; j < indexesOfString.item2.length; j++){
      if (indexesOfBracket[i] >= indexesOfString.item2[j].item1 && indexesOfBracket[i] <= indexesOfString.item2[j].item2){
        insideString = true;
        break;
      }
    }
    if (!insideString){
      return Tuple2(true, indexesOfBracket[i]);
    }
  }
  return Tuple2(false, -1);
}

Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> addLineBreakAfterBracket(List<String> textInLines, String intend, List<dynamic> brackets, String settings,
                                          List<Tuple2<String, List<Tuple2<int, int>>>> indexesOfStrings){
  //In dart, java, go, scala { is the designation of the beginning of a function.
  //In python instead of the {, the : .
  String text = textInLines.join('\n');
  if (brackets.isEmpty) {
    return Tuple2(text, indexesOfStrings);
  }
  List<int> indexes = [];
  for (int i = 0; i < brackets.length; i++){
    int firstIndex;
    int secondIndex;
    for (int j = 0; j < textInLines.length; j++){
      firstIndex = symbolContains(brackets[i][0], textInLines[j], indexesOfStrings[j]).item2;
      secondIndex = symbolContains(brackets[i][1], textInLines[j], indexesOfStrings[j]).item2;
      if (firstIndex != -1) {
        firstIndex += textInLines.sublist(0, j).join().length;
      }
      if (secondIndex != -1) {
        secondIndex += textInLines.sublist(0, j).join().length;
      }
      if (firstIndex != -1 && secondIndex != -1){
        indexes.add(firstIndex<secondIndex ? firstIndex : secondIndex);
        break;
      }
      else if (firstIndex != -1){
        indexes.add(firstIndex);
        break;
      }
      else if (secondIndex != -1){
        indexes.add(secondIndex);
        break;
      }
    }
    if (indexes.length != i + 1){
      indexes.add(-1);
    }
  }
  int min = indexes.reduce(max);
  int indexOfmin = indexes.indexOf(min);
  for (int i = 0;i < indexes.length; i++){
    if (indexes[i] < min && indexes[i] != -1){
      min = indexes[i];
      indexOfmin = i;
    }
  }
  String bracket = brackets[indexOfmin];

  String refactorText = "";
  List<Tuple2<String, List<Tuple2<int, int>>>> newIndexesOfStrings = [];
  int i = 0;

  while(textInLines.length - i > 0){
    Tuple2<bool, int> containsFirstBracket = symbolContains(bracket[0], textInLines[i], indexesOfStrings[i]);
    Tuple2<bool, int> containsSecondBracket = symbolContains(bracket[1], textInLines[i], indexesOfStrings[i]);

    if (containsFirstBracket.item1 && (containsSecondBracket.item2 == -1 || containsFirstBracket.item2 < containsSecondBracket.item2)) {
      int indexOfBracket = containsFirstBracket.item2;
      String beforeBracket = textInLines[i].substring(0, indexOfBracket + 1);
      String afterBracket = textInLines[i].substring(indexOfBracket + 1);

      List<String> linesWithAfterBracket = textInLines.sublist(i + 1);
      List<Tuple2<String, List<Tuple2<int, int>>>> indexesOfStringsWithAfterBracket = indexesOfStrings.sublist(i + 1);
      
      List<Tuple2<int, int>> indexesForBeforeBracket = [];
      for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
        if (indexesOfStrings[i].item2[j].item2 < indexOfBracket){
          indexesForBeforeBracket.add(indexesOfStrings[i].item2[j]);
        }
      }
      newIndexesOfStrings.add(Tuple2(indexesForBeforeBracket.isNotEmpty ? haveString : simple, indexesForBeforeBracket));

      if (afterBracket.trim() != '') {
        linesWithAfterBracket.insert(0, afterBracket);
        List<Tuple2<int, int>> indexesForAfterBracket = [];
        for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
          if (indexesOfStrings[i].item2[j].item1 > indexOfBracket){
            indexesForAfterBracket.add(Tuple2(indexesOfStrings[i].item2[j].item1 - indexOfBracket - 1, 
                                                          indexesOfStrings[i].item2[j].item2 - indexOfBracket - 1));
          }
        }
        indexesOfStringsWithAfterBracket.insert(0,Tuple2(indexesForAfterBracket.isNotEmpty ? 
                                                          haveString : simple, indexesForAfterBracket));
      }
      Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> result = 
            addLineBreakAfterBracket(linesWithAfterBracket, intend + settings, brackets, settings, indexesOfStringsWithAfterBracket);
      refactorText += intend + beforeBracket + '\n' + result.item1;
      newIndexesOfStrings.addAll(result.item2);
      return Tuple2(refactorText, newIndexesOfStrings);
    }
    else if (containsSecondBracket.item1){
      int indexOfBracket = containsSecondBracket.item2;
      String beforeBracket = textInLines[i].substring(0, indexOfBracket);
      String afterBracket = textInLines[i].substring(indexOfBracket + 1);
      String newIntend = intend.length > settings.length ? intend.substring(settings.length) : '';

      List<String> linesWithAfterBracket = textInLines.sublist(i + 1);
      List<Tuple2<String, List<Tuple2<int, int>>>> indexesOfStringsWithAfterBracket = indexesOfStrings.sublist(i + 1);

      List<Tuple2<int, int>> indexesForBeforeBracket = [];
      for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
        if (indexesOfStrings[i].item2[j].item2 < indexOfBracket){
          indexesForBeforeBracket.add(indexesOfStrings[i].item2[j]);
        }
      }
      newIndexesOfStrings.add(Tuple2(indexesForBeforeBracket.isNotEmpty ? haveString : simple, indexesForBeforeBracket));

      if (afterBracket.trim() != ''){
        linesWithAfterBracket.insert(0, afterBracket);
        List<Tuple2<int, int>> indexesForAfterBracket = [];
        for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
          if (indexesOfStrings[i].item2[j].item1 > indexOfBracket){
            indexesForAfterBracket.add(Tuple2(indexesOfStrings[i].item2[j].item1 - indexOfBracket - 1, 
                                                          indexesOfStrings[i].item2[j].item2 - indexOfBracket - 1));
          }
        }
        indexesOfStringsWithAfterBracket.insert(0,Tuple2(indexesForAfterBracket.isNotEmpty ? 
                                                          haveString : simple, indexesForAfterBracket));
      }

      Tuple2<String, List<Tuple2<String, List<Tuple2<int, int>>>>> result = addLineBreakAfterBracket(linesWithAfterBracket, newIntend, brackets, settings, indexesOfStringsWithAfterBracket);
      if (beforeBracket.trim() == ''){
        refactorText += newIntend + bracket[1] + '\n' + result.item1;
      }
      else {
        refactorText += intend + beforeBracket + '\n ' + newIntend + bracket[1] + '\n' + result.item1;
      }
      newIndexesOfStrings.addAll(result.item2);
      
      return Tuple2(refactorText, newIndexesOfStrings);
    }
    else {
      if (indexesOfStrings[i].item1 != multline){
        if (indexesOfStrings[i].item2.length > 0){
          if (indexesOfStrings[i].item2[0].item1 != 0) {
            int lengthOfIntend = textInLines[i].length - textInLines[i].trimLeft().length;
            List<Tuple2<int, int>> indexesForBeforeBracket = [];
            for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
              indexesForBeforeBracket.add(Tuple2(indexesOfStrings[i].item2[j].item1 - lengthOfIntend + intend.length, 
                                              indexesOfStrings[i].item2[j].item2 - lengthOfIntend + intend.length));
            }
            refactorText += intend + textInLines[i].trimLeft() + '\n';
            newIndexesOfStrings.add(Tuple2(haveString, indexesForBeforeBracket));
          }
          else {
            refactorText += textInLines[i] + '\n';
            newIndexesOfStrings.add(indexesOfStrings[i]);
          }
        }
        else {
          refactorText += intend + textInLines[i].trimLeft() + '\n';
          newIndexesOfStrings.add(Tuple2(simple, []));
        }
      }
      else {
        refactorText += textInLines[i] + '\n';
        newIndexesOfStrings.add(indexesOfStrings[i]);
      }
      i++;
    }
  }
  return Tuple2(refactorText, newIndexesOfStrings);
}

String addLineBreakAfterFunctionColon(String text, String intend, List<Tuple2<String, List<Tuple2<int, int>>>> indexesOfStrings){
  String refactorText = "";
  text = text.trimRight();
  final List<String> textInLines= text.split('\n');
  for (int i = 0; i < textInLines.length; i++){
    Tuple2<bool, int> containsColon = symbolContains(':', textInLines[i], indexesOfStrings[i]);
    if (containsColon.item1) {
      int indexOfColon = containsColon.item2;
      String beforeColon = textInLines[i].substring(0, indexOfColon + 1);
      String afterColon = textInLines[i].substring(indexOfColon + 1);
      List<Tuple2<String, List<Tuple2<int, int>>>> indexesForAfterColonList = [];
      if (afterColon.trim() != ''){
        List<Tuple2<int, int>> indexesForAfterColon = [];
        for (int j = 0; j < indexesOfStrings[i].item2.length; j++){
          if (indexesOfStrings[i].item2[j].item1 > indexOfColon){
            indexesForAfterColon.add(Tuple2(indexesOfStrings[i].item2[j].item1 - indexOfColon - 1, indexesOfStrings[i].item2[j].item2 - indexOfColon - 1));
          }
        }
        indexesForAfterColonList.add(Tuple2(indexesForAfterColon.isNotEmpty ? haveString : simple, indexesForAfterColon));
        refactorText +=  beforeColon + '\n' + intend + addLineBreakAfterFunctionColon(afterColon, intend, indexesForAfterColonList);
      }
      else {
        refactorText += textInLines[i] + '\n';
      }
    }
    else {
      refactorText += textInLines[i] + '\n';
    }
  }
  return refactorText;
}
