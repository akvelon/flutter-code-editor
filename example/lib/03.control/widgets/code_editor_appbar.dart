import 'package:flutter/material.dart';

import 'dropdown_selector.dart';

class CodeEditorAppbar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final List<String> languages;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback? onReset;
  final ValueChanged<String> onThemeChanged;
  final String selectedLanguage;
  final String selectedTheme;
  final List<String> themes;

  const CodeEditorAppbar({
    required this.height,
    required this.languages,
    required this.onLanguageChanged,
    this.onReset,
    required this.onThemeChanged,
    required this.selectedLanguage,
    required this.selectedTheme,
    required this.themes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 13,
      color: Colors.deepPurple[900],
      child: Row(
        children: [
          const Spacer(flex: 2),
          const Text(
            'Code Editor by Akvelon',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
          const Spacer(flex: 35),
          DropdownSelector(
            icon: Icons.code,
            onChanged: onLanguageChanged,
            value: selectedLanguage,
            values: languages,
          ),
          const Spacer(),
          DropdownSelector(
            icon: Icons.color_lens,
            onChanged: onThemeChanged,
            value: selectedTheme,
            values: themes,
          ),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text('Reset', style: TextStyle(color: Colors.white)),
            onPressed: onReset,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
