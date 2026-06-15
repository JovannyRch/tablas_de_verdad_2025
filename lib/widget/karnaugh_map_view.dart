import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/class/karnaugh_map.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';

/// Distinct colors assigned to Karnaugh groups (and their legend entries).
const List<Color> kKarnaughGroupColors = [
  Color(0xFFE53935), // red
  Color(0xFF1E88E5), // blue
  Color(0xFF43A047), // green
  Color(0xFFFB8C00), // orange
  Color(0xFF8E24AA), // purple
  Color(0xFF00897B), // teal
  Color(0xFFD81B60), // pink
  Color(0xFF6D4C41), // brown
];

Color karnaughGroupColor(int index) =>
    kKarnaughGroupColors[index % kKarnaughGroupColors.length];

/// Renders a Karnaugh map: gray-coded headers, cell values with minterm
/// indices, and the minimal-cover groups drawn as colored rounded rectangles.
/// Groups that wrap around an edge are drawn open-ended on that side.
class KarnaughMapView extends StatelessWidget {
  final KarnaughResult result;
  final bool isDark;

  const KarnaughMapView({
    super.key,
    required this.result,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const labelSize = 36.0;
    final targetValue = result.form == KarnaughForm.sop ? 1 : 0;
    final t = AppLocalizations.of(context);

    // The colored group overlay is a CustomPaint — invisible to screen
    // readers. Describe each implicant (term + size) so the minimal cover is
    // conveyed without sight. Constant functions have no groups.
    String? groupsSemantics;
    if (t != null) {
      if (result.groups.isEmpty) {
        groupsSemantics = t.karnaughConstant;
      } else {
        final parts = <String>[t.a11yKarnaughMap(result.groups.length)];
        for (int i = 0; i < result.groups.length; i++) {
          final g = result.groups[i];
          parts.add(t.a11yKarnaughGroup(i + 1, g.term, g.cells.length));
        }
        groupsSemantics = parts.join('. ');
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth - labelSize;
        final cellSize = (available / result.colCount).clamp(40.0, 72.0);
        final gridWidth = cellSize * result.colCount;
        final gridHeight = cellSize * result.rowCount;

        final headerStyle = TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white54 : Colors.black45,
        );

        return Center(
          child: SizedBox(
            width: labelSize + gridWidth,
            height: labelSize + gridHeight,
            child: Stack(
              children: [
                // Corner: row variables \ column variables
                Positioned(
                  left: 0,
                  top: 0,
                  width: labelSize,
                  height: labelSize,
                  child: Center(
                    child: Text(
                      '${result.rowVariables}\\${result.colVariables}',
                      style: headerStyle.copyWith(fontSize: 10),
                    ),
                  ),
                ),
                // Column labels (gray code)
                for (int c = 0; c < result.colCount; c++)
                  Positioned(
                    left: labelSize + c * cellSize,
                    top: 0,
                    width: cellSize,
                    height: labelSize,
                    child: Center(
                      child: Text(result.colLabels[c], style: headerStyle),
                    ),
                  ),
                // Row labels (gray code)
                for (int r = 0; r < result.rowCount; r++)
                  Positioned(
                    left: 0,
                    top: labelSize + r * cellSize,
                    width: labelSize,
                    height: cellSize,
                    child: Center(
                      child: Text(result.rowLabels[r], style: headerStyle),
                    ),
                  ),
                // Cells
                for (int r = 0; r < result.rowCount; r++)
                  for (int c = 0; c < result.colCount; c++)
                    Positioned(
                      left: labelSize + c * cellSize,
                      top: labelSize + r * cellSize,
                      width: cellSize,
                      height: cellSize,
                      child: _KarnaughCell(
                        value: result.values[r][c],
                        minterm: result.minterms[r][c],
                        isTarget: result.values[r][c] == targetValue,
                        isDark: isDark,
                      ),
                    ),
                // Group overlay
                Positioned(
                  left: labelSize,
                  top: labelSize,
                  width: gridWidth,
                  height: gridHeight,
                  child: Semantics(
                    container: true,
                    label: groupsSemantics,
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _GroupPainter(
                          result: result,
                          cellSize: cellSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KarnaughCell extends StatelessWidget {
  final int value;
  final int minterm;
  final bool isTarget;
  final bool isDark;

  const _KarnaughCell({
    required this.value,
    required this.minterm,
    required this.isTarget,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark ? Colors.white12 : Colors.black12;
    final baseColor = isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor, width: 0.5),
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.015),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 4,
            top: 2,
            child: Text(
              '$minterm',
              style: TextStyle(
                fontSize: 9,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          ),
          Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: isTarget ? FontWeight.w800 : FontWeight.w400,
                color: isTarget ? baseColor : baseColor.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Contiguous fragment of a (possibly wrapping) range along one axis.
class _RangeFragment {
  final int start;
  final int span;
  final bool openBefore; // continues past the start edge (wraps)
  final bool openAfter; // continues past the end edge (wraps)

  const _RangeFragment(
    this.start,
    this.span, {
    this.openBefore = false,
    this.openAfter = false,
  });
}

class _GroupPainter extends CustomPainter {
  final KarnaughResult result;
  final double cellSize;

  _GroupPainter({required this.result, required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    for (int i = 0; i < result.groups.length; i++) {
      final group = result.groups[i];
      final color = karnaughGroupColor(i);
      final inset = (3.0 + i * 3.0).clamp(3.0, cellSize / 2 - 6);

      final rowFragments = _fragments({
        for (final cell in group.cells) cell.row,
      }, result.rowCount);
      final colFragments = _fragments({
        for (final cell in group.cells) cell.col,
      }, result.colCount);

      final fill =
          Paint()
            ..style = PaintingStyle.fill
            ..color = color.withValues(alpha: 0.10);
      final stroke =
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..color = color;

      for (final rowFrag in rowFragments) {
        for (final colFrag in colFragments) {
          // Open sides extend past the clipped canvas so the border and
          // rounded corners disappear, signaling the group continues on
          // the opposite edge of the map.
          final extension = cellSize * 0.4;

          double left = colFrag.start * cellSize + inset;
          double width = colFrag.span * cellSize - 2 * inset;
          if (colFrag.openBefore) {
            left -= extension + inset;
            width += extension + inset;
          }
          if (colFrag.openAfter) width += extension + inset;

          double top = rowFrag.start * cellSize + inset;
          double height = rowFrag.span * cellSize - 2 * inset;
          if (rowFrag.openBefore) {
            top -= extension + inset;
            height += extension + inset;
          }
          if (rowFrag.openAfter) height += extension + inset;

          final rrect = RRect.fromRectAndRadius(
            Rect.fromLTWH(left, top, width, height),
            const Radius.circular(10),
          );
          canvas.drawRRect(rrect, fill);
          canvas.drawRRect(rrect, stroke);
        }
      }
    }
  }

  /// Decompose the covered positions along one axis into 1 or 2 contiguous
  /// fragments. Implicants always project to a contiguous run modulo the
  /// axis length (subcubes in gray code), so a wrap splits into exactly two.
  List<_RangeFragment> _fragments(Set<int> positions, int dim) {
    final span = positions.length;
    if (span == dim) return [_RangeFragment(0, dim)];

    // Find the start: the position whose predecessor is not covered.
    int start = positions.first;
    for (final p in positions) {
      if (!positions.contains((p - 1 + dim) % dim)) {
        start = p;
        break;
      }
    }

    if (start + span <= dim) return [_RangeFragment(start, span)];

    // Wrapping run: tail fragment at the end + head fragment at the start.
    return [
      _RangeFragment(start, dim - start, openAfter: true),
      _RangeFragment(0, start + span - dim, openBefore: true),
    ];
  }

  @override
  bool shouldRepaint(_GroupPainter oldDelegate) =>
      oldDelegate.result != result || oldDelegate.cellSize != cellSize;
}
