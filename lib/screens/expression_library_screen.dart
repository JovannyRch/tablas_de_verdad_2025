import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:tablas_de_verdad_2025/api/api.dart';
import 'package:tablas_de_verdad_2025/class/truth_table.dart';
import 'package:tablas_de_verdad_2025/model/list_response.dart';
import 'package:tablas_de_verdad_2025/model/settings_model.dart';
import 'package:tablas_de_verdad_2025/l10n/app_localizations.dart';
import 'package:tablas_de_verdad_2025/utils/rewarded_ad_helper.dart';
import 'package:tablas_de_verdad_2025/utils/show_pro_version_dialog.dart';
import 'package:tablas_de_verdad_2025/utils/show_snackbar.dart';
import 'package:tablas_de_verdad_2025/widget/expression_card.dart';
import 'package:tablas_de_verdad_2025/const/colors.dart';

class ExpressionLibraryScreen extends StatefulWidget {
  const ExpressionLibraryScreen({super.key});

  @override
  State<ExpressionLibraryScreen> createState() =>
      _ExpressionLibraryScreenState();
}

class Filter {
  final String label;
  final TruthTableType value;

  Filter(this.label, this.value);
}

class _ExpressionLibraryScreenState extends State<ExpressionLibraryScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Expression> _allExpressions = []; // Todas las expresiones del JSON
  final List<Expression> _filteredExpressions = []; // Expresiones filtradas
  bool _isLoading = false;
  TruthTableType? _selectedType;
  bool _onlyVideos = false;
  bool _hasUnlockedFullList = false; // Si el usuario desbloqueó viendo un ad
  late AppLocalizations t;
  late Settings _settings;
  late RewardedAdHelper _rewardedAdHelper;

  static const int FREE_EXPRESSIONS_LIMIT =
      10; // Límite para usuarios gratuitos

  @override
  void initState() {
    super.initState();
    _rewardedAdHelper = RewardedAdHelper();
    _fetchExpressions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _rewardedAdHelper.dispose();
    super.dispose();
  }

  Future<void> _fetchExpressions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Obtener todas las expresiones del JSON estático
      final ListResponse response = await Api.getListExpressions(1, '');

      setState(() {
        if (response.data != null) {
          _allExpressions.clear();
          _allExpressions.addAll(response.data!);
          _applyFilters();
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching expressions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredExpressions.clear();

    List<Expression> filtered = List.from(_allExpressions);

    // Filtrar por tipo si está seleccionado
    if (_selectedType != null) {
      String typeStr = type;
      filtered = filtered.where((expr) => expr.type == typeStr).toList();
    }

    // Filtrar por videos si está activado
    if (_onlyVideos) {
      filtered =
          filtered
              .where(
                (expr) =>
                    expr.youtubeUrl != null && expr.youtubeUrl!.isNotEmpty,
              )
              .toList();
    }

    _filteredExpressions.addAll(filtered);
  }

  void _onFilterSelected(TruthTableType selectedType) {
    setState(() {
      if (_selectedType == selectedType) {
        _selectedType = null;
      } else {
        _selectedType = selectedType;
      }
      _applyFilters();
    });
  }

  void _onVideosToggled() {
    setState(() {
      _onlyVideos = !_onlyVideos;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    t = AppLocalizations.of(context)!;
    _settings = context.watch<Settings>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: Text(t.expressionLibrary),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(child: _buildExpressionList()),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(
                  t.contingency,
                  TruthTableType.contingency,
                  Colors.amber,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  t.tautology,
                  TruthTableType.tautology,
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  t.contradiction,
                  TruthTableType.contradiction,
                  Colors.red,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  t.only_tutorials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const Spacer(),
                Switch.adaptive(
                  value: _onlyVideos,
                  activeColor: kSeedColor,
                  onChanged: (_) => _onVideosToggled(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, TruthTableType value, Color color) {
    final bool isSelected = _selectedType == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _onFilterSelected(value),
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color:
            isSelected
                ? color
                : (isDark ? Colors.white60 : Colors.black.withOpacity(0.6)),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color:
              isSelected ? color : (isDark ? Colors.white10 : Colors.black12),
        ),
      ),
    );
  }

  Widget _buildExpressionList() {
    if (_isLoading && _filteredExpressions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredExpressions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No expressions found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final bool shouldLimit = !_settings.isProVersion && !_hasUnlockedFullList;
    final int itemCount =
        shouldLimit
            ? FREE_EXPRESSIONS_LIMIT.clamp(0, _filteredExpressions.length)
            : _filteredExpressions.length;

    final bool hasMoreExpressions =
        _filteredExpressions.length > FREE_EXPRESSIONS_LIMIT;
    final bool showUnlockButton = shouldLimit && hasMoreExpressions;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount + (showUnlockButton ? 1 : 0),
      itemBuilder: (context, index) {
        if (showUnlockButton && index == itemCount) {
          return _buildUnlockCard();
        }

        final expression = _filteredExpressions[index];
        return ExpressionCard(
          expression: expression,
          showAds: (index != 0 && index % 4 == 0),
        );
      },
    );
  }

  Widget _buildUnlockCard() {
    final remainingCount = _filteredExpressions.length - FREE_EXPRESSIONS_LIMIT;

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF3B82F6)], // Indigo to Blue
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  t.unlockLibraryTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  t.expressionsRemaining(remainingCount),
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _unlockWithAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3B82F6),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_fill),
                      const SizedBox(width: 12),
                      Text(
                        t.watchVideoFree,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _showProDialog,
                  icon: const Icon(Icons.diamond_outlined, color: Colors.white),
                  label: Text(
                    t.upgradePro,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _unlockWithAd() async {
    if (kDebugMode) {
      print('🔓 Iniciando proceso de desbloqueo con ad...');
    }

    final success = await _rewardedAdHelper.showRewardedAd();

    if (kDebugMode) {
      print('🎯 Resultado del rewarded ad: $success');
    }

    if (success) {
      // Dar un pequeño delay para asegurar que el ad se cerró completamente
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _hasUnlockedFullList = true;
        });

        if (kDebugMode) {
          print(
            '✅ Lista desbloqueada. Total expresiones: ${_filteredExpressions.length}',
          );
        }

        showSnackBarMessage(context, t.libraryUnlocked);

        // Scroll hacia abajo para mostrar las nuevas expresiones
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    } else {
      if (kDebugMode) {
        print('❌ No se pudo mostrar el rewarded ad');
      }
      if (mounted) {
        showSnackBarMessage(context, t.adNotAvailable);
      }
    }
  }

  Future<void> _showProDialog() async {
    await showProVersionDialog(context, _settings, t);
  }

  String get type {
    switch (_selectedType) {
      case TruthTableType.contingency:
        return "CONTINGENCY";
      case TruthTableType.tautology:
        return "TAUTOLOGY";
      case TruthTableType.contradiction:
        return "CONTRADICTION";
      default:
        return '';
    }
  }
}
