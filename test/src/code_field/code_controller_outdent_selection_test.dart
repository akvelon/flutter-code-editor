// ignore_for_file: avoid_redundant_argument_values, prefer_final_locals, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

void main() {
  group('Unfolded', () {
    CodeController controller = CodeController(
      params: const EditorParams(tabSpaces: 2),
    );
    final indentLength = controller.params.tabSpaces;
    final indent = ' ' * indentLength;

    test('Selection is collapsed', () {
      final examples = [
        const _Example(
          'WHEN start == -1 && end == -1 SHOULD NOT modify anything',
          initialFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
  aaaa
aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: -1,
            extentOffset: -1,
          ),
          expectedSelection: TextSelection(
            baseOffset: -1,
            extentOffset: -1,
          ),
        ),
        const _Example(
          'WHEN at the start of the first line '
          'SHOULD modify first line',
          initialFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedFullText: '''
aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
aaaa
aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 0,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 5,
          ),
        ),
        const _Example(
          'WHEN at the start of a non-first line '
          'SHOULD modify that line',
          initialFullText: '''
  aaaa
    aaaa
aaaa
''',
          expectedFullText: '''
  aaaa
  aaaa
aaaa
''',
          expectedVisibleText: '''
  aaaa
  aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: 7,
            extentOffset: 7,
          ),
          expectedSelection: TextSelection(
            baseOffset: 7,
            extentOffset: 14,
          ),
        ),
        _Example(
          'WHEN at the middle of a line SHOULD modify that line',
          initialFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedFullText: '''
aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
aaaa
aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: 4,
            extentOffset: 4,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 5,
          ),
        ),
        const _Example(
          'WHEN at the beginning whiteSpace '
          'that is not a full indent '
          'SHOULD remove all beginning whitespaces of the line ',
          initialFullText: '''
  aaaa
 aaaa
aaaa
''',
          expectedFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
  aaaa
aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: 8,
            extentOffset: 8,
          ),
          expectedSelection: TextSelection(
            baseOffset: 7,
            extentOffset: 12,
          ),
        ),
        _Example(
          'WHEN at the end of a line '
          'SHOULD modify that line',
          initialFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedFullText: '''
aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
aaaa
aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: 6,
            extentOffset: 6,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 5,
          ),
        ),
      ];

      for (final example in examples) {
        controller.text = example.initialFullText;
        controller.selection = example.initialSelection;
        controller.outdentSelection();

        expect(
          controller.value.text,
          example.expectedVisibleText,
          reason: example.name,
        );
        expect(
          controller.code.text,
          example.expectedFullText,
          reason: example.name,
        );
        expect(
          controller.code.visibleText,
          controller.text,
          reason: example.name,
        );
        expect(
          controller.value.selection,
          example.expectedSelection,
          reason: example.name,
        );
      }
    });

    test('Selection is a range', () {
      final examples = [
        _Example(
          'WHEN the entire document is selectd '
          'SHOULD outdent all lines',
          initialFullText: '''
  AAAA
      AAAA
  AAAA''',
          expectedFullText: '''
AAAA
    AAAA
AAAA''',
          expectedVisibleText: '''
AAAA
    AAAA
AAAA''',
          initialSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 24,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 18,
          ),
        ),
        _Example(
          'WHEN lines that doesn\'t have indent are selected '
          'SHOULD NOT outdent that lines',
          initialFullText: '''
AAAA
      AAAA
  AAAA
''',
          expectedFullText: '''
AAAA
    AAAA
AAAA
''',
          expectedVisibleText: '''
AAAA
    AAAA
AAAA
''',
          initialSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 22,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 19,
          ),
        ),
        _Example(
          'Outdent SHOULD NOT unfold folded comment at line 0 '
          'and folded imports',
          initialFullText: '''
/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.beam.examples;

import java.util.Arrays;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.Count;
import org.apache.beam.sdk.transforms.Filter;
import org.apache.beam.sdk.transforms.FlatMapElements;
import org.apache.beam.sdk.transforms.MapElements;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.TypeDescriptors;

  aaaa {

  }
''',
          expectedFullText: '''
/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.apache.beam.examples;

import java.util.Arrays;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.Count;
import org.apache.beam.sdk.transforms.Filter;
import org.apache.beam.sdk.transforms.FlatMapElements;
import org.apache.beam.sdk.transforms.MapElements;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.TypeDescriptors;

aaaa {

}
''',
          expectedVisibleText: '''
/*
package org.apache.beam.examples;

aaaa {

}
''',
          initialSelection: TextSelection(baseOffset: 38, extentOffset: 51),
          expectedSelection: TextSelection(baseOffset: 38, extentOffset: 48),
        ),
      ];

      for (final example in examples) {
        controller = CodeController(
          params: EditorParams(tabSpaces: 2),
          language: java,
        );
        controller.text = example.initialFullText;
        controller.foldCommentAtLineZero();
        controller.foldImports();
        controller.selection = example.initialSelection;
        controller.outdentSelection();

        expect(
          controller.value.text,
          example.expectedVisibleText,
          reason: example.name,
        );
        expect(
          controller.code.text,
          example.expectedFullText,
          reason: example.name,
        );
        expect(
          controller.code.visibleText,
          controller.text,
          reason: example.name,
        );
        expect(
          controller.value.selection,
          example.expectedSelection,
          reason: example.name,
        );
      }
    });
  });
}

class _Example {
  final String name;
  final String initialFullText;
  final String? initialVisibleText;
  final String expectedFullText;
  final String expectedVisibleText;
  final List<int>? blockIndexesToFold;
  final TextSelection initialSelection;
  final TextSelection expectedSelection;

  const _Example(
    this.name, {
    required this.initialFullText,
    this.initialVisibleText,
    required this.expectedFullText,
    required this.expectedVisibleText,
    this.blockIndexesToFold,
    required this.initialSelection,
    required this.expectedSelection,
  });
}
