import 'package:flutter/widgets.dart';
import '../code_controller.dart';

class CommentUncommentIntent extends Intent {
  const CommentUncommentIntent();
}

class CommentUncommentAction extends Action<CommentUncommentIntent> {
  final CodeController controller;

  CommentUncommentAction({
    required this.controller,
  });

  @override
  Object? invoke(CommentUncommentIntent intent) {
    controller.commentOutOrUncommentSelection();
    return null;
  }
}
