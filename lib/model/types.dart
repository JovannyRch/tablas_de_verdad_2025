import 'package:flutter/material.dart';

enum ViewMode { table, map }

enum ResultType { sop, pos }

class Position {
  final int row;
  final int column;

  Position({required this.row, required this.column});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          column == other.column;

  @override
  int get hashCode => row.hashCode ^ column.hashCode;
}

class BoxColor {
  final int row;
  final int column;
  final BoxDecoration style;

  BoxColor({required this.row, required this.column, required this.style});
}

class VectorResultItem {
  final String value;
  final TextStyle style;

  VectorResultItem({required this.value, required this.style});
}
