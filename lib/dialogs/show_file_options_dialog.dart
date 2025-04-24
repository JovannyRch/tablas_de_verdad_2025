import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

Future<void> showFileOptionsDialog(BuildContext context, String filePath) {
  final fileName = filePath.split('/').last;
  return showDialog<void>(
    context: context,
    builder:
        (_) => SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.blueAccent),
              const SizedBox(width: 8),
              const Text('Opciones de archivo'),
            ],
          ),
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new, color: Colors.green),
              title: const Text('Abrir archivo'),
              subtitle: Text(fileName, style: const TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.of(context).pop();
                OpenFile.open(filePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Compartir archivo'),
              subtitle: Text(fileName, style: const TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.of(context).pop();

                SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(filePath)],
                    text: 'Te comparto este archivo.',
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.redAccent),
              title: const Text('Cancelar'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
  );
}
