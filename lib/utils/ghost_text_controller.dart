import 'package:flutter/material.dart';

class GhostTextEditingController extends TextEditingController {
  GhostTextEditingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> children = [];

    // Add existing text
    children.add(TextSpan(text: text, style: style));

    // Calculate ghost closing marks using a stack for correct nesting
    final List<String> stack = [];

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      if (char == '(') {
        stack.add(')');
      } else if (char == '[') {
        stack.add(']');
      } else if (char == '{') {
        stack.add('}');
      } else if (char == ')' || char == ']' || char == '}') {
        if (stack.isNotEmpty && stack.last == char) {
          stack.removeLast();
        }
      }
    }

    if (stack.isNotEmpty) {
      // The ghost text is the reverse of the stack to close in order
      final ghostText = stack.reversed.join();
      children.add(
        TextSpan(
          text: ghostText,
          style: style?.copyWith(
            color:
                style.color?.withOpacity(0.3) ?? Colors.grey.withOpacity(0.3),
          ),
        ),
      );
    }

    return TextSpan(children: children, style: style);
  }
}
