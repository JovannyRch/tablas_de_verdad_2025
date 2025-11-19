import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OptionType {
  final String name;
  final OperatorType value;

  OptionType({required this.name, required this.value});
}

class OperatorTypeSelector extends StatefulWidget {
  const OperatorTypeSelector({super.key});

  @override
  _OperatorTypeSelectorState createState() => _OperatorTypeSelectorState();
}

class _OperatorTypeSelectorState extends State<OperatorTypeSelector> {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    final t = AppLocalizations.of(context)!;

    final options = [
      OptionType(name: t.boolean, value: OperatorType.boolean),
      OptionType(name: t.logic, value: OperatorType.logic),
      OptionType(name: t.minterm, value: OperatorType.minterms),
    ];

    return Wrap(
      spacing: 8.0,
      children: List<Widget>.generate(options.length, (int index) {
        return ChoiceChip(
          label: Text(options[index].name),
          selected: settings.operatorType == options[index].value,
          onSelected: (bool selected) {
            if (settings.operatorType == options[index].value) {
              setState(() {
                settings.update(operatorsType: OperatorType.none);
              });
              return;
            }
            setState(() {
              settings.update(operatorsType: options[index].value);
            });
          },
        );
      }),
    );
  }
}
