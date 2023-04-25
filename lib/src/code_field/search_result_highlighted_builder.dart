import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../flutter_code_editor.dart';

class SearchResultHighlightedBuilder {
  int _currentIndex = 0;
  bool _isLastMatchProcessed = false;
  bool _isCurrentMatchHandled = false;
  late SearchMatch _currentMatch;
  late Iterator<SearchMatch> _matches;
  final _result = <InlineSpan>[];
  String? _currentText = '';

  final SearchResult searchResult;

  SearchResultHighlightedBuilder({
    required this.searchResult,
  }) {
    if (searchResult.matches.isEmpty) {
      return;
    }

    _matches = searchResult.matches.iterator;
    _isLastMatchProcessed = !_matches.moveNext();
    _currentMatch = _matches.current;
  }

  int get _currentEnd => _currentIndex + (_currentText?.length ?? 0);
  bool get _isCurrentMatchOutOfRange =>
      _currentEnd < _currentMatch.start ||
      _currentIndex > _currentMatch.end ||
      _isLastMatchProcessed;

  bool get _isMatchFromMiddleTillEnd =>
      _currentIndex <= _currentMatch.start &&
      _currentEnd > _currentMatch.start &&
      _currentEnd < _currentMatch.end;

  bool get _isTextInsideMatchCompletely =>
      _currentIndex >= _currentMatch.start &&
      _currentIndex + _currentText!.length <= _currentMatch.end;

  bool get _isMatchFullyInsideText =>
      _currentIndex + _currentText!.length >= _currentMatch.start &&
      _currentIndex + _currentText!.length >= _currentMatch.end &&
      !_isLastMatchProcessed;

  TextSpan build(TextSpan span) {
    if (searchResult.matches.isEmpty) {
      return span;
    }

    span.visitChildren((span) {
      var localIndex = 0;
      final searchStyle = span.style?.copyWith(
            backgroundColor: Colors.yellow,
            color: Colors.black,
          ) ??
          const TextStyle(
            backgroundColor: Colors.yellow,
            color: Colors.black,
          );

      _currentText = (span as TextSpan).text;
      if (_currentText == null || _currentText!.isEmpty) {
        return true;
      }

      if (_isCurrentMatchOutOfRange) {
        _result.add(span);
        _currentIndex += _currentText!.length;
        return true;
      }

      if (_isMatchFromMiddleTillEnd) {
        _result.add(
          TextSpan(
            text: _currentText!.substring(
              0,
              _currentMatch.start - _currentIndex,
            ),
            style: span.style,
          ),
        );

        _result.add(
          TextSpan(
            text: _currentText!.substring(
                _currentMatch.start - _currentIndex, _currentText!.length),
            style: searchStyle,
          ),
        );
        _currentIndex += _currentText!.length;
        return true;
      }

      if (_isTextInsideMatchCompletely) {
        _result.add(
          TextSpan(
            text: _currentText!.substring(0, _currentText!.length),
            style: searchStyle,
          ),
        );

        if (_currentIndex + _currentText!.length == _currentMatch.end) {
          _isLastMatchProcessed = !_matches.moveNext();
          if (!_isLastMatchProcessed) {
            _currentMatch = _matches.current;
          }
        }
        _currentIndex += _currentText!.length;
        return true;
      }

      while (_isMatchFullyInsideText) {
        _result.add(
          TextSpan(
            text: _currentText!.substring(
              localIndex,
              math.max(
                localIndex,
                _currentMatch.start - _currentIndex,
              ),
            ),
            style: span.style,
          ),
        );
        localIndex = math.max(localIndex, _currentMatch.start - _currentIndex);

        _result.add(
          TextSpan(
            text: _currentText!
                .substring(localIndex, _currentMatch.end - _currentIndex),
            style: searchStyle,
          ),
        );
        localIndex = _currentMatch.end - _currentIndex;
        _isLastMatchProcessed = !_matches.moveNext();
        if (!_isLastMatchProcessed) {
          _currentMatch = _matches.current;
        }
      }

      if (_currentIndex >= _currentMatch.start &&
          _currentIndex + _currentText!.length <= _currentMatch.end &&
          !_isLastMatchProcessed) {
        _result.add(
          TextSpan(
            text: _currentText!
                .substring(localIndex, _currentMatch.end - _currentIndex),
            style: searchStyle,
          ),
        );

        if (_currentIndex + _currentText!.length == _currentMatch.end) {
          _isLastMatchProcessed = !_matches.moveNext();
          if (!_isLastMatchProcessed) {
            _currentMatch = _matches.current;
          }
        }
        _currentIndex += _currentText!.length;
        return true;
      } else {
        _result.add(
          TextSpan(
            text: _currentText!.substring(localIndex, _currentText!.length),
            style: span.style,
          ),
        );
      }

      if (_isCurrentMatchHandled) {
        _isLastMatchProcessed = !_matches.moveNext();
        if (!_isLastMatchProcessed) {
          _currentMatch = _matches.current;
        }
        _isCurrentMatchHandled = false;
      }

      _currentIndex += _currentText!.length;
      return true;
    });

    return TextSpan(children: _result);
  }
}
