import 'package:tablas_de_verdad_2025/model/settings_model.dart';

String getCellValue(String localName, TruthFormat format, String cell) {
 
  if (cell == '0') {
    if (format == TruthFormat.vf) {
      return 'F';
    }
    return cell;
  }
  if (format == TruthFormat.binary) {
    return cell;
  }

  if (localName == 'es') {
    return 'V';
  } else {
    return 'T';
  }
}
