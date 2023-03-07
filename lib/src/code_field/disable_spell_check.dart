const jsDisableSpellCheck = '''
var disableSpellCheck = setInterval(function () {
      var elements = document.getElementsByTagName('flt-glass-pane');
      for (let child of elements[0].shadowRoot.children) {
        if (child.tagName.toLowerCase() == 'form') {
          let textFields = child.getElementsByTagName('textarea');
          for (let textField of textFields) {
            textField.setAttribute('spellcheck', 'false');
          }
        }
      }
    }, 1000);
''';
