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

    // Calculate ghost parentheses
    int openCount = 0;

    for (int i = 0; i < text.length; i++) {
      if (text[i] == '(') {
        openCount++;
      } else if (text[i] == ')') {
        if (openCount > 0) {
          openCount--;
        }
      }
    }

    if (openCount > 0) {
      final ghostText = ')' * openCount;
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
