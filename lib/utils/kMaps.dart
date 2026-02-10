import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/model/types.dart';

class KMaps {
  List<List<List<dynamic>>> squares;
  final int typeMap;
  final ResultType typeSol;
  String result = '';
  String mathExpression = '';
  final double borderWidth = 5.0;
  final double borderRadius = 10.0;
  List<BoxColor> boxColors = [];
  final List<String> colors = [
    '#FF0000', // red
    '#0000FF', // blue
    '#008000', // green
    '#FFA500', // orange
    '#50C878', // emerald
    '#ADD8E6', // lightblue
    '#CD7F32', // bronze
    '#FF6699', // pink
  ];
  List<VectorResultItem> vectorResult = [];
  List<String> circuitVector = [];

  KMaps({required this.typeMap, required this.typeSol, required this.squares});

  void algorithm() {
    int dimCol, dimRig;
    final int val = typeSol == ResultType.sop ? 1 : 0;

    if (typeMap == 4) {
      dimCol = 4;
      dimRig = 4;
    } else if (typeMap == 3) {
      dimCol = 4;
      dimRig = 2;
    } else {
      dimCol = 2;
      dimRig = 2;
    }

    var groups = List.generate(
      dimRig,
      (i) => List.generate(dimCol, (j) => <int>[]),
    );

    var index = 0;

    for (int i = 0; i < dimRig; i++) {
      for (int j = 0; j < dimCol; j++) {
        var count = 0;

        if (squares[i][j][0] == val) {
          var tempI = i;
          var tempJ = j;

          if (j == dimCol - 1) {
            bool ok = true;
            int count2 = 0;

            for (int altezza = i; altezza < dimRig && ok; altezza++) {
              if (squares[altezza][dimCol - 1][0] == val &&
                  squares[altezza][0][0] == val) {
                groups[altezza][0].add(index);
                groups[altezza][dimCol - 1].add(index);
                count2++;
              } else {
                ok = false;
              }
            }

            if (count2 > 0) {
              index++;
              if (!isPower(2, count2)) {
                groups[i + count2 - 1][0].removeLast();
                groups[i + count2 - 1][dimCol - 1].removeLast();
              }
            }
          }

          if (i == dimRig - 1) {
            bool ok = true;
            int count2 = 0;

            for (int colonna = j; colonna < dimCol && ok; colonna++) {
              if (squares[dimRig - 1][colonna][0] == val &&
                  squares[0][colonna][0] == val) {
                groups[dimRig - 1][colonna].add(index);
                groups[0][colonna].add(index);
                count2++;
              } else {
                ok = false;
              }
            }

            if (count2 > 0) {
              index++;
              if (!isPower(2, count2)) {
                groups[dimRig - 1][j + count2 - 1].removeLast();
                groups[0][j + count2 - 1].removeLast();
              }
            }
          }

          do {
            groups[tempI][tempJ].add(index);
            count++;
            tempJ++;
          } while (tempJ < dimCol && squares[tempI][tempJ][0] == val);

          if (!isPower(2, count)) {
            groups[tempI][tempJ - 1].removeLast();
            count--;
          }

          int countVer;
          int depth = 100;
          bool isOk = true;

          for (int spostamento = 0; spostamento < count; spostamento++) {
            tempI = i + 1;
            tempJ = j + spostamento;
            countVer = 1;

            while (tempI < dimRig && countVer < depth) {
              if (squares[tempI][tempJ][0] != val) {
                if (spostamento != 0 && countVer != depth) {
                  var rig = tempI;
                  if (!isPower(2, spostamento)) {
                    if (!isPower(2, countVer)) rig--;

                    groups[tempI][tempJ].add(index);

                    if (tempI >= depth) {
                      depth = tempI;
                    } else {
                      depth--;
                    }

                    for (; rig <= depth; rig++) {
                      for (int col = tempJ - 1; col <= spostamento; col++) {
                        groups[rig][col].removeLast();
                      }
                    }
                    isOk = false;
                  }
                }
                break;
              }
              groups[tempI][tempJ].add(index);
              tempI++;
              countVer++;
            }

            if (countVer < depth) depth = countVer;

            if (!isPower(2, countVer) && isOk) {
              groups[tempI - 1][tempJ].removeLast();
              depth--;
            }
          }
          index++;
        }
      }
    }

    groupUp(_deepCopy(groups));
  }

  void groupUp(List<List<List<int>>> values) {
    List<List<Map<String, int>>> groups = [];
    int dimCol, dimRig;
    final int val = typeSol == ResultType.sop ? 1 : 0;

    if (typeMap == 4) {
      dimCol = 4;
      dimRig = 4;
    } else if (typeMap == 3) {
      dimCol = 4;
      dimRig = 2;
    } else {
      dimCol = 2;
      dimRig = 2;
    }

    if (squares[0][0][0] == val &&
        squares[0][dimCol - 1][0] == val &&
        squares[dimRig - 1][0][0] == val &&
        squares[dimRig - 1][dimCol - 1][0] == val) {
      List<Map<String, int>> group1 = [
        {'riga': 0, 'col': 0},
        {'riga': 0, 'col': dimCol - 1},
        {'riga': dimRig - 1, 'col': 0},
        {'riga': dimRig - 1, 'col': dimCol - 1},
      ];
      groups.add(group1);
    }

    for (int i = 0; i < dimRig; i++) {
      for (int j = 0; j < dimCol; j++) {
        if (squares[i][j][0] == val) {
          if (values[i][j].isEmpty) continue;

          var index = values[i][j][0];
          var inizioRiga = i;
          var inizioCol = j;
          List<Map<String, int>> group1 = [];
          List<Map<String, int>> group2 = [];

          if (j == dimCol - 1) {
            while (inizioRiga < dimRig &&
                values[inizioRiga][j].isNotEmpty &&
                values[inizioRiga][j][0] == index &&
                values[inizioRiga][0].isNotEmpty &&
                values[inizioRiga][0][0] == index) {
              group1.add({'riga': inizioRiga, 'col': 0});
              group1.add({'riga': inizioRiga, 'col': j});
              values[inizioRiga][j].removeAt(0);
              values[inizioRiga][0].removeAt(0);
              inizioRiga++;
            }

            if (group1.isNotEmpty) {
              groups.add(group1);
              group1 = [];
              if (values[i][j].isNotEmpty) {
                index = values[i][j][0];
              }
            }

            inizioRiga = i;
            inizioCol = j;
          }

          if (i == dimRig - 1) {
            while (inizioCol < dimCol &&
                values[i][inizioCol].isNotEmpty &&
                values[i][inizioCol][0] == index &&
                values[0][inizioCol].isNotEmpty &&
                values[0][inizioCol][0] == index) {
              group1.add({'riga': i, 'col': inizioCol});
              group1.add({'riga': 0, 'col': inizioCol});
              values[0][inizioCol].removeAt(0);
              values[i][inizioCol].removeAt(0);
              inizioCol++;
            }

            if (group1.isNotEmpty) {
              group1.sort((a, b) => a['riga']!.compareTo(b['riga']!));
              groups.add(group1);
              group1 = [];
              if (values[i][j].isNotEmpty) {
                index = values[i][j][0];
              }
            }

            inizioRiga = i;
            inizioCol = j;
          }

          if (values[i][j].isEmpty) continue;
          index = values[i][j][0];

          while (inizioCol < dimCol &&
              values[inizioRiga][inizioCol].isNotEmpty &&
              values[inizioRiga][inizioCol][0] == index) {
            inizioCol++;
          }

          while (inizioRiga < dimRig &&
              values[inizioRiga][inizioCol - 1].isNotEmpty &&
              values[inizioRiga][inizioCol - 1][0] == index) {
            inizioRiga++;
          }

          for (int fineRiga = i; fineRiga < inizioRiga; fineRiga++) {
            for (int fineCol = j; fineCol < inizioCol; fineCol++) {
              group1.add({'riga': fineRiga, 'col': fineCol});
            }
          }

          groups.add(group1);

          inizioRiga = i;
          inizioCol = j;

          while (inizioRiga < dimRig &&
              values[inizioRiga][inizioCol].isNotEmpty &&
              values[inizioRiga][inizioCol][0] == index) {
            inizioRiga++;
          }

          while (inizioCol < dimCol &&
              values[inizioRiga - 1][inizioCol].isNotEmpty &&
              values[inizioRiga - 1][inizioCol][0] == index) {
            inizioCol++;
          }

          for (int fineRiga = i; fineRiga < inizioRiga; fineRiga++) {
            for (int fineCol = j; fineCol < inizioCol; fineCol++) {
              group2.add({'riga': fineRiga, 'col': fineCol});
            }
          }

          bool equal = true;
          if (group1.length == group2.length) {
            for (int v = 0; v < group1.length && equal; v++) {
              if (group1[v]['riga'] != group2[v]['riga'] ||
                  group1[v]['col'] != group2[v]['col']) {
                equal = false;
              }
            }
          } else {
            groups.add(group2);
          }

          if (!equal) groups.add(group2);

          for (int k = 0; k < dimRig; k++) {
            for (int z = 0; z < dimCol; z++) {
              if (values[k][z].isNotEmpty && values[k][z][0] == index) {
                values[k][z].removeAt(0);
              }
            }
          }
        }
      }
    }

    cleanAlgorithm(_deepCopyGroups(groups));
  }

  void cleanAlgorithm(List<List<Map<String, int>>> groups) {
    groups.sort((a, b) => a.length.compareTo(b.length));
    groups = groups.reversed.toList();

    var temp = _deepCopyGroups(groups);

    for (int i = 0; i < temp.length; i++) {
      for (int j = i + 1; j < temp.length; j++) {
        if (temp[i].length < temp[j].length) {
          int p = i;
          while (p < temp.length - 1 && temp[p].length < temp[p + 1].length) {
            var t = temp[p];
            temp[p] = temp[p + 1];
            temp[p + 1] = t;

            var tg = groups[p];
            groups[p] = groups[p + 1];
            groups[p + 1] = tg;
            p++;
          }
        }

        for (int k = 0; k < temp[i].length; k++) {
          for (int l = 0; l < temp[j].length; l++) {
            if (temp[i][k]['riga'] == temp[j][l]['riga'] &&
                temp[i][k]['col'] == temp[j][l]['col']) {
              temp[j].removeAt(l);
              break;
            }
          }
        }
      }
    }

    for (int v = 0; v < groups.length; v++) {
      bool eliminato = true;
      if (temp[v].isNotEmpty) {
        for (int index = 0; index < groups[v].length && eliminato; index++) {
          var obj1 = groups[v][index];
          bool trovato = false;

          for (int k = 0; k < groups.length && !trovato; k++) {
            if (v != k && temp[k].isNotEmpty) {
              var valueIndex = groups[k].indexWhere(
                (obj2) =>
                    obj1['riga'] == obj2['riga'] && obj1['col'] == obj2['col'],
              );
              if (valueIndex != -1) trovato = true;
            }
          }

          if (!trovato) eliminato = false;
        }
      }

      if (eliminato) temp[v] = [];
    }

    solution(temp, groups);
    drawGroup(temp, groups);
  }

  void solution(
    List<List<Map<String, int>>> temp,
    List<List<Map<String, int>>> groups,
  ) {
    final matrice = squares;
    var alp = ['A', 'B', 'C', 'D'];
    String soluzione = '';
    String soluzione2 = '';
    String soluzione3 = '';
    List<String> vettoreSol = [];
    List<String> vettoreSol2 = [];
    circuitVector = [];

    for (int i = 0; i < temp.length; i++) {
      if (temp[i].isNotEmpty) {
        int k = 0;
        int elementoR = groups[i][0]['riga']!;
        int elementoC = groups[i][0]['col']!;

        int ner = 0;
        while (ner < groups[i].length && groups[i][ner]['riga'] == elementoR) {
          ner++;
        }

        // CONTROLLO RIGA
        int t = 0;
        String coord = matrice[elementoR][elementoC][1];

        while (t < coord.length) {
          int j = 1;
          bool flag = true;

          while (j < groups[i].length && groups[i][j]['riga'] == elementoR) {
            if (coord[t] != matrice[elementoR][groups[i][j]['col']!][1][t]) {
              flag = false;
              break;
            }
            j++;
          }

          if (flag) {
            if (typeSol == ResultType.sop) {
              if (coord[t] == '0') {
                soluzione += "'${alp[k]}";
                soluzione2 += "${alp[k]}\u0305";
                soluzione3 += "${alp[k]}'";
              } else {
                soluzione += alp[k];
                soluzione2 += alp[k];
                soluzione3 += alp[k];
              }
              soluzione3 += '.';
            } else {
              if (coord[t] == '0') {
                soluzione += alp[k];
                soluzione2 += alp[k];
                soluzione3 += alp[k];
              } else {
                soluzione += "'${alp[k]}";
                soluzione2 += "${alp[k]}\u0305";
                soluzione3 += "${alp[k]}'";
              }
              soluzione += '+';
              soluzione2 += '+';
              soluzione3 += '+';
            }
          }
          k++;
          t++;
        }

        // CONTROLLO COLONNA
        t = 0;
        coord = matrice[elementoR][elementoC][2];

        while (t < coord.length) {
          int j = ner;
          bool flag = true;

          while (j < groups[i].length && groups[i][j]['col'] == elementoC) {
            if (coord[t] != matrice[groups[i][j]['riga']!][elementoC][2][t]) {
              flag = false;
              break;
            }
            j += ner;
          }

          if (flag) {
            if (typeSol == ResultType.sop) {
              if (coord[t] == '0') {
                soluzione += "'${alp[k]}";
                soluzione2 += "${alp[k]}\u0305";
                soluzione3 += "${alp[k]}'";
              } else {
                soluzione += alp[k];
                soluzione2 += alp[k];
                soluzione3 += alp[k];
              }
              soluzione3 += '.';
            } else {
              if (coord[t] == '0') {
                soluzione += alp[k];
                soluzione2 += alp[k];
                soluzione3 += alp[k];
              } else {
                soluzione += "'${alp[k]}";
                soluzione2 += "${alp[k]}\u0305";
                soluzione3 += "${alp[k]}'";
              }
              soluzione += '+';
              soluzione2 += '+';
              soluzione3 += '+';
            }
          }
          k++;
          t++;
        }

        if (typeSol == ResultType.pos) {
          soluzione = soluzione.substring(0, soluzione.length - 1);
          soluzione2 = soluzione2.substring(0, soluzione2.length - 1);
          soluzione3 = soluzione3.substring(0, soluzione3.length - 1);
        }

        vettoreSol.add(soluzione);
        vettoreSol2.add(soluzione2);
        circuitVector.add(soluzione3);

        soluzione = '';
        soluzione2 = '';
        soluzione3 = '';
      }
    }

    if (vettoreSol.isEmpty || vettoreSol[0].isEmpty) {
      if (matrice[0][0][0] == 0) {
        vettoreSol = ['0'];
        vettoreSol2 = ['0'];
      } else {
        vettoreSol = ['1'];
        vettoreSol2 = ['1'];
      }
    }

    result = vettoreSol.join(typeSol == ResultType.sop ? ' + ' : ' · ');
    mathExpression = vettoreSol2.join(
      typeSol == ResultType.sop ? ' + ' : ' · ',
    );

    // Generate vector result
    vectorResult = [];
    for (int index = 0; index < vettoreSol2.length; index++) {
      vectorResult.add(
        VectorResultItem(
          value: vettoreSol2[index],
          style: TextStyle(
            color: _parseColor(colors[index]),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      if (index < vettoreSol2.length - 1) {
        vectorResult.add(
          VectorResultItem(
            value: typeSol == ResultType.sop ? ' + ' : ' · ',
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
        );
      }
    }
  }

  bool isPower(int x, int y) {
    if (x == 1) return y == 1;

    int pow = 1;
    while (pow < y) {
      pow *= x;
    }

    return pow == y;
  }

  void drawGroup(
    List<List<Map<String, int>>> temp,
    List<List<Map<String, int>>> groups,
  ) {
    int c = -1;
    boxColors = [];

    for (int i = 0; i < temp.length; i++) {
      if (temp[i].isNotEmpty && groups[i].length != (1 << typeMap)) {
        c++;
        int j = 0;
        int firstElCol = groups[i][0]['col']!;
        int firstElRig = groups[i][0]['riga']!;

        while (j < groups[i].length) {
          final col = groups[i][j]['col']!;
          final row = groups[i][j]['riga']!;

          BoxDecoration element = BoxDecoration(
            border: Border.all(color: _parseColor(colors[c]), width: 0),
          );

          bool destra = checkElInGroups(j, groups[i], 'destra');
          bool sotto = checkElInGroups(j, groups[i], 'sotto');
          bool sinistra = checkElInGroups(j, groups[i], 'sinistra');
          bool sopra = checkElInGroups(j, groups[i], 'sopra');

          String position = _determinePosition(
            destra: destra,
            sotto: sotto,
            sinistra: sinistra,
            sopra: sopra,
            j: j,
            col: col,
            row: row,
            firstElCol: firstElCol,
            firstElRig: firstElRig,
            groupLength: groups[i].length,
          );

          element = _addBorder(element, position, _parseColor(colors[c]));
          j++;

          boxColors.add(BoxColor(row: row, column: col, style: element));
        }
      }
    }
  }

  String _determinePosition({
    required bool destra,
    required bool sotto,
    required bool sinistra,
    required bool sopra,
    required int j,
    required int col,
    required int row,
    required int firstElCol,
    required int firstElRig,
    required int groupLength,
  }) {
    if (destra) {
      if (sotto) {
        if (sinistra) {
          if (col == firstElCol) {
            return 'topLeft';
          } else if (j == groupLength ~/ 2 - 1 || j == groupLength - 1) {
            return 'topRight';
          } else {
            return 'top';
          }
        } else if (sopra) {
          if (j == groupLength - 2 || j == groupLength - 1) {
            return 'bottomLeft';
          } else if (row == firstElRig) {
            return 'topLeft';
          } else {
            return 'left';
          }
        } else {
          return 'topLeft';
        }
      } else if (sopra) {
        if (sinistra) {
          if (col == firstElCol) {
            return 'bottomLeft';
          } else if (j == groupLength - 1 || j == groupLength ~/ 2 - 1) {
            return 'bottomRight';
          } else {
            return 'bottom';
          }
        } else {
          return 'bottomLeft';
        }
      } else if (sinistra) {
        if (j == 0) {
          return 'closedLeft';
        } else if (j == groupLength - 1) {
          return 'closedRight';
        } else {
          return 'top-bottom';
        }
      } else {
        return 'closedLeft';
      }
    } else if (sopra) {
      if (sinistra) {
        if (sotto) {
          if (row == firstElRig) {
            return 'topRight';
          } else if (j == groupLength - 1 || j == groupLength - 2) {
            return 'bottomRight';
          } else {
            return 'right';
          }
        } else {
          return 'bottomRight';
        }
      } else if (sotto) {
        if (j == 0) {
          return 'closedTop';
        } else if (j == groupLength - 1) {
          return 'closedBottom';
        } else {
          return 'right-left';
        }
      } else {
        return 'closedBottom';
      }
    } else if (sinistra) {
      if (sotto) {
        return 'topRight';
      } else {
        return 'closedRight';
      }
    } else if (sotto) {
      return 'closedTop';
    } else {
      return 'monoGroup';
    }
  }

  bool checkElInGroups(int j, List<Map<String, int>> groups, String lato) {
    final matrix = squares;
    int r = matrix.length;
    int c = matrix[0].length;

    if (typeMap == 3) {
      r = 2;
      c = 4;
    }

    for (int k = 0; k < groups.length; k++) {
      if (lato == 'destra' &&
          groups[k]['col'] == (groups[j]['col']! + 1) % c &&
          groups[k]['riga'] == groups[j]['riga']! % r) {
        return true;
      }
      if (lato == 'sotto' &&
          groups[k]['col'] == groups[j]['col']! % c &&
          groups[k]['riga'] == (groups[j]['riga']! + 1) % r) {
        return true;
      }
      if (lato == 'sinistra') {
        int col = groups[j]['col']! - 1;
        if (col < 0) col = c - 1;
        if (groups[k]['col'] == col % c &&
            groups[k]['riga'] == groups[j]['riga']! % r) {
          return true;
        }
      }
      if (lato == 'sopra') {
        int riga = groups[j]['riga']! - 1;
        if (riga < 0) riga = r - 1;
        if (groups[k]['col'] == groups[j]['col']! % c &&
            groups[k]['riga'] == riga % r) {
          return true;
        }
      }
    }
    return false;
  }

  BoxDecoration _addBorder(
    BoxDecoration element,
    String position,
    Color color,
  ) {
    switch (position) {
      case 'top':
        return element.copyWith(
          border: Border(top: BorderSide(color: color, width: borderWidth)),
        );
      case 'right':
        return element.copyWith(
          border: Border(right: BorderSide(color: color, width: borderWidth)),
        );
      case 'bottom':
        return element.copyWith(
          border: Border(bottom: BorderSide(color: color, width: borderWidth)),
        );
      case 'left':
        return element.copyWith(
          border: Border(left: BorderSide(color: color, width: borderWidth)),
        );
      case 'topRight':
        return element.copyWith(
          border: Border(
            top: BorderSide(color: color, width: borderWidth),
            right: BorderSide(color: color, width: borderWidth),
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(borderRadius),
          ),
        );
      case 'topLeft':
        return element.copyWith(
          border: Border(
            top: BorderSide(color: color, width: borderWidth),
            left: BorderSide(color: color, width: borderWidth),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
          ),
        );
      case 'bottomRight':
        return element.copyWith(
          border: Border(
            bottom: BorderSide(color: color, width: borderWidth),
            right: BorderSide(color: color, width: borderWidth),
          ),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(borderRadius),
          ),
        );
      case 'bottomLeft':
        return element.copyWith(
          border: Border(
            bottom: BorderSide(color: color, width: borderWidth),
            left: BorderSide(color: color, width: borderWidth),
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius),
          ),
        );
      case 'closedLeft':
        return element.copyWith(
          border: Border(
            left: BorderSide(color: color, width: borderWidth),
            top: BorderSide(color: color, width: borderWidth),
            bottom: BorderSide(color: color, width: borderWidth),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            bottomLeft: Radius.circular(borderRadius),
          ),
        );
      case 'closedRight':
        return element.copyWith(
          border: Border(
            right: BorderSide(color: color, width: borderWidth),
            top: BorderSide(color: color, width: borderWidth),
            bottom: BorderSide(color: color, width: borderWidth),
          ),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(borderRadius),
            bottomRight: Radius.circular(borderRadius),
          ),
        );
      case 'closedTop':
        return element.copyWith(
          border: Border(
            top: BorderSide(color: color, width: borderWidth),
            left: BorderSide(color: color, width: borderWidth),
            right: BorderSide(color: color, width: borderWidth),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
          ),
        );
      case 'closedBottom':
        return element.copyWith(
          border: Border(
            bottom: BorderSide(color: color, width: borderWidth),
            left: BorderSide(color: color, width: borderWidth),
            right: BorderSide(color: color, width: borderWidth),
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(borderRadius),
            bottomRight: Radius.circular(borderRadius),
          ),
        );
      case 'top-bottom':
        return element.copyWith(
          border: Border(
            top: BorderSide(color: color, width: borderWidth),
            bottom: BorderSide(color: color, width: borderWidth),
          ),
        );
      case 'right-left':
        return element.copyWith(
          border: Border(
            right: BorderSide(color: color, width: borderWidth),
            left: BorderSide(color: color, width: borderWidth),
          ),
        );
      case 'monoGroup':
        return element.copyWith(
          border: Border.all(color: color, width: borderWidth),
          borderRadius: BorderRadius.circular(borderRadius),
        );
      default:
        return element;
    }
  }

  String getCircuitResult() => result;
  String getMathExpression() => mathExpression;
  List<BoxColor> getBoxColors() => boxColors;
  List<VectorResultItem> getVectorResult() => vectorResult;
  List<String> getCircuitVector() => circuitVector;

  // Helper methods
  List<List<List<int>>> _deepCopy(List<List<List<int>>> original) {
    return original
        .map((row) => row.map((cell) => List<int>.from(cell)).toList())
        .toList();
  }

  List<List<Map<String, int>>> _deepCopyGroups(
    List<List<Map<String, int>>> original,
  ) {
    return original
        .map(
          (group) => group.map((item) => Map<String, int>.from(item)).toList(),
        )
        .toList();
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}
