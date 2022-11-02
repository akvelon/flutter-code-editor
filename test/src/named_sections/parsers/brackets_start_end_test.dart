import 'package:flutter_code_editor/src/named_sections/named_section.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/brackets_start_end.dart';
import 'package:flutter_code_editor/src/single_line_comments/single_line_comment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BracketsStartEndNamedSectionParser. Parses comments', () {
    final comments = [
      //
      SingleLineComment(lineIndex: 13, innerContent: ' no named section'),

      SingleLineComment(lineIndex: 14, innerContent: '[END never_started ]'),
      SingleLineComment(lineIndex: 11, innerContent: '[START never_ending]'),

      SingleLineComment(lineIndex: 16, innerContent: '[START outer]'),
      SingleLineComment(lineIndex: 18, innerContent: '[START inner]'),
      SingleLineComment(lineIndex: 21, innerContent: '[END inner]'),
      SingleLineComment(lineIndex: 21, innerContent: '[END outer]'),

      SingleLineComment(lineIndex: 80, innerContent: '[START line][END line]'),
      SingleLineComment(lineIndex: 81, innerContent: '[END swap][START swap]'),
      SingleLineComment(lineIndex: 82, innerContent: '[START split_line]'),
      SingleLineComment(lineIndex: 82, innerContent: '[ END split_line]'),
      SingleLineComment(lineIndex: 83, innerContent: '[START 2]'),
      SingleLineComment(lineIndex: 84, innerContent: '[START _]'),

      SingleLineComment(lineIndex: 71, innerContent: 'a [START text_before]'),
      SingleLineComment(lineIndex: 72, innerContent: 'a [END text_before]'),
      SingleLineComment(lineIndex: 73, innerContent: '[START text_after] b'),
      SingleLineComment(lineIndex: 74, innerContent: '[END text_after] b'),

      SingleLineComment(lineIndex: 35, innerContent: '[END overlapping1]'),
      SingleLineComment(lineIndex: 30, innerContent: '[START overlapping2]'),
      SingleLineComment(lineIndex: 24, innerContent: '[START overlapping1]'),
      SingleLineComment(lineIndex: 40, innerContent: '[END  overlapping2]'),

      SingleLineComment(lineIndex: 50, innerContent: '[START no-dashes]'),
      SingleLineComment(lineIndex: 51, innerContent: '[START no spaces]'),
      SingleLineComment(lineIndex: 52, innerContent: 'START no_bracket1]'),
      SingleLineComment(lineIndex: 53, innerContent: '[START no_bracket2'),
      SingleLineComment(lineIndex: 54, innerContent: '[!START nothing_before]'),
      SingleLineComment(lineIndex: 55, innerContent: '[END nothing_after!]'),
      SingleLineComment(lineIndex: 56, innerContent: '[ END ]'),

      SingleLineComment(lineIndex: 30, innerContent: '[Start non_all_caps]'),
      SingleLineComment(lineIndex: 30, innerContent: '[End non_all_caps]'),

      SingleLineComment(lineIndex: 41, innerContent: '[START reversed]'),
      SingleLineComment(lineIndex: 40, innerContent: '[END reversed]'),

      SingleLineComment(lineIndex: 42, innerContent: '[START duplicate_start]'),
      SingleLineComment(lineIndex: 41, innerContent: '[START duplicate_start]'),
      SingleLineComment(lineIndex: 45, innerContent: '[END duplicate_start]'),
      SingleLineComment(lineIndex: 43, innerContent: '[START duplicate_start]'),

      SingleLineComment(lineIndex: 61, innerContent: '[START duplicate_end]'),
      SingleLineComment(lineIndex: 65, innerContent: '[END duplicate_end]'),
      SingleLineComment(lineIndex: 67, innerContent: '[END duplicate_end]'),
      SingleLineComment(lineIndex: 65, innerContent: '[END duplicate_end]'),

      SingleLineComment(lineIndex: 72, innerContent: '[START START]'),
      SingleLineComment(lineIndex: 73, innerContent: '[END START]'),
      SingleLineComment(lineIndex: 74, innerContent: '[START END]'),
      SingleLineComment(lineIndex: 75, innerContent: '[END END]'),

      SingleLineComment(lineIndex: -3, innerContent: '[START before0]'),
      SingleLineComment(lineIndex: -2, innerContent: '[END before0]'),
    ];

    const expected = [
      NamedSection(firstLine: 0, lastLine: 14, name: 'never_started'),
      NamedSection(firstLine: 11, lastLine: null, name: 'never_ending'),
      NamedSection(firstLine: 16, lastLine: 21, name: 'outer'),
      NamedSection(firstLine: 18, lastLine: 21, name: 'inner'),
      NamedSection(firstLine: 24, lastLine: 35, name: 'overlapping1'),
      NamedSection(firstLine: 30, lastLine: 40, name: 'overlapping2'),
      NamedSection(firstLine: 41, lastLine: 45, name: 'duplicate_start'),
      NamedSection(firstLine: 61, lastLine: 67, name: 'duplicate_end'),
      NamedSection(firstLine: 71, lastLine: 72, name: 'text_before'),
      NamedSection(firstLine: 72, lastLine: 73, name: 'START'),
      NamedSection(firstLine: 73, lastLine: 74, name: 'text_after'),
      NamedSection(firstLine: 74, lastLine: 75, name: 'END'),
      NamedSection(firstLine: 80, lastLine: 80, name: 'line'),
      NamedSection(firstLine: 81, lastLine: 81, name: 'swap'),
      NamedSection(firstLine: 82, lastLine: 82, name: 'split_line'),
      NamedSection(firstLine: 83, lastLine: null, name: '2'),
      NamedSection(firstLine: 84, lastLine: null, name: '_'),
    ];

    const parser = BracketsStartEndNamedSectionParser();
    final parsed = parser.parse(
      singleLineComments: comments,
    );

    expect(parsed, expected);
  });
}
