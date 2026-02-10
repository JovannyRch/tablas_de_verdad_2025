import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';

Future<void> showFileOptionsDialog(
  BuildContext context,
  String filePath,
  AppLocalizations t,
) {
  final fileName = filePath.split('/').last;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder:
        (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  // Accent Gradient top right
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.15),
                            Colors.cyan.withOpacity(0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // File Icon with Gradient
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00BCD4).withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.insert_drive_file_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          t.fileOptions,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          fileName,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 32),
                        // Options
                        _FileOptionItem(
                          icon: Icons.open_in_new_rounded,
                          title: t.openFile,
                          color: const Color(0xFF4CAF50),
                          onTap: () {
                            Navigator.of(dialogContext).pop();
                            OpenFile.open(filePath);
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _FileOptionItem(
                          icon: Icons.share_rounded,
                          title: t.shareFile,
                          color: const Color(0xFF2196F3),
                          onTap: () {
                            Navigator.of(dialogContext).pop();
                            SharePlus.instance.share(
                              ShareParams(
                                files: [XFile(filePath)],
                                text: t.shareFileMessage,
                              ),
                            );
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(height: 24),
                        // Cancel Button
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            foregroundColor:
                                isDark ? Colors.white38 : Colors.black38,
                          ),
                          child: Text(
                            t.cancel,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
  );
}

class _FileOptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  const _FileOptionItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.black12,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
