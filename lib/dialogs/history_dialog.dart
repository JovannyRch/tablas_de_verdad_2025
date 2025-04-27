import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/db/database.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/go_to_solution.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class HistoryDialog extends StatefulWidget {
  const HistoryDialog({Key? key}) : super(key: key);

  @override
  State<HistoryDialog> createState() => _HistoryDialogState();
}

class _HistoryDialogState extends State<HistoryDialog> {
  late Future<List<String>> _future;

  @override
  void initState() {
    super.initState();
    _future = getHistory();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(t.history),
      content: SizedBox(
        width: double.maxFinite,
        child: FutureBuilder<List<String>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snap.data ?? [];
            if (data.isEmpty) {
              return Text(t.no_history);
            }

            return ListView.separated(
              itemCount: data.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder:
                  (_, i) => Dismissible(
                    key: ValueKey(data[i]),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: Colors.red,
                      child: const Icon(Icons.delete),
                    ),
                    onDismissed: (_) async {
                      await deleteExpression(data[i]);
                    },
                    child: ListTile(
                      title: Text(data[i]),
                      onTap: () => Navigator.pop(context, data[i]),
                    ),
                  ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await clearHistory(); // Ya la tienes en tu DB helper
            setState(() => _future = getHistory());
          },
          child: const Text('Borrar todo'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
