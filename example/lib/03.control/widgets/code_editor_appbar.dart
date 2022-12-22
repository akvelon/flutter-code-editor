import 'package:flutter/material.dart';

import 'dropdown_selector.dart';

class CodeEditorAppbar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final List<String?> languages;
  final List<String?> themes;
  final String? title;
  final Function(String?)? onLanguageChanged;
  final Function(String?)? onThemeChanged;

  final String selectedLanguage;
  final String selectedTheme;
  
  final VoidCallback? onReset;

  const CodeEditorAppbar({
    super.key,
    required this.height,
    required this.languages,
    required this.themes,
    required this.selectedLanguage,
    required this.selectedTheme,
    this.title,
    this.onLanguageChanged,
    this.onThemeChanged,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 13,
      color: Colors.deepPurple[900],
      child: Row(
        children: [
          const Spacer(flex: 2),
          Text(
            title ?? 'Code Editor by Akvelon',
            style: const TextStyle(fontSize: 28, color: Colors.white),
          ),
          const Spacer(flex: 35),
          DropdownSelector(
            choices: languages,
            value: selectedLanguage,
            icon: Icons.code,
            onChanged: onLanguageChanged,
          ),
          const Spacer(),
          DropdownSelector(
            choices: themes,
            value: selectedTheme,
            icon: Icons.color_lens,
            onChanged: onThemeChanged,
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
