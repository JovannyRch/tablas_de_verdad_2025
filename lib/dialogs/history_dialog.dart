import 'package:flutter/material.dart';
import 'package:tablas_de_verdad_2025/db/database.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/utils/go_to_solution.dart';
import 'package:provider/provider.dart';

class HistoryDialog extends StatefulWidget {
  const HistoryDialog({super.key});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Row(
        children: [
          Icon(
            Icons.history_rounded,
            color: isDark ? Colors.white70 : Colors.black54,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            t.history,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400, // Fixed height for consistency
        child: FutureBuilder<List<String>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = (snap.data ?? []).reversed.toList(); // Newest first

            if (data.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off_rounded,
                      size: 64,
                      color:
                          isDark
                              ? Colors.white10
                              : Colors.black.withOpacity(0.05),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.no_history,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.separated(
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final expression = data[i];
                  return Dismissible(
                    key: ValueKey(expression),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (_) async {
                      await deleteExpression(expression);
                      // Omitimos el setState aquí para que la animación sea fluida si ya se borró de la DB
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, expression),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  isDark
                                      ? Colors.white10
                                      : Colors.black.withOpacity(0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  expression,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Courier',
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: isDark ? Colors.white24 : Colors.black26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () async {
            await clearHistory();
            setState(() => _future = getHistory());
          },
          style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
          child: Text(t.clear_all),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
            foregroundColor: isDark ? Colors.white : Colors.black87,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(t.close),
        ),
      ],
    );
  }
}
