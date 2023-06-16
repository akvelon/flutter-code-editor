enum EditType {
  backspaceBeforeCollapsedSelection,
  deleteAfterCollapsedSelection,
  deleteSelection,
  insertAtCollapsedSelection,
  replaceSelection,
  unchanged,

  /// A change beyond a user's ability to interact with the editor
  /// like replacing an unselected text in one action.
  other,
}
