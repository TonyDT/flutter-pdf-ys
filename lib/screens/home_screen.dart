import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/constants/app_styles.dart';
import '../core/l10n/app_localizations.dart';
import '../core/premium/premium_provider.dart';
import '../core/theme/theme_provider.dart';
import '../services/pdf_service.dart';
import 'pdf_viewer_screen.dart';
import 'premium_screen.dart';
import 'tools_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<File> _pdfFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdfs();
  }

  Future<void> _loadPdfs() async {
    setState(() => _isLoading = true);
    final files = await PdfService.getSavedPdfs();
    setState(() {
      _pdfFiles = files;
      _isLoading = false;
    });
  }

  Future<void> _pickPdf() async {
    final file = await PdfService.pickPdfFile();
    if (file == null) return;

    final savedFile = await PdfService.copyToAppDir(file);
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PdfViewerScreen(pdfFile: savedFile)),
      ).then((_) => _loadPdfs());
    }
  }

  void _openPdf(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PdfViewerScreen(pdfFile: file)),
    );
  }

  Future<void> _deletePdf(File file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).t('delete')),
        content: Text(AppLocalizations.of(context).t('delete_pdf_confirm')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppLocalizations.of(context).t('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(AppLocalizations.of(context).t('delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PdfService.deletePdf(file);
      _loadPdfs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final premiumState = ref.watch(premiumProvider);
    final isDark = ref.watch(themeProvider).isDarkMode;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.t('pdf_pro'), style: AppFonts.h3),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            tooltip: l10n.t('toggle_theme'),
          ),
          IconButton(
            icon: const Icon(Icons.build_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ToolsScreen())),
            tooltip: l10n.t('tools'),
          ),
          if (!premiumState.isPremium)
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PremiumScreen())),
              child: Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: AppStyles.premiumBadgeDecoration,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.workspace_premium,
                        color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text('Pro',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _pdfFiles.isEmpty
              ? _buildEmptyState()
              : _buildPdfList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _pickPdf,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.textOnPrimary),
        label: Text(l10n.t('open_pdf'),
            style: const TextStyle(
                color: AppColors.textOnPrimary, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf_outlined,
              size: 80, color: AppColors.textHint.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).t('no_pdfs_found'),
              style: AppFonts.h3.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context).t('open_pdf'),
              style: AppFonts.bodyMedium.copyWith(color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _buildPdfList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pdfFiles.length,
      itemBuilder: (context, index) {
        final file = _pdfFiles[index];
        final fileName = file.path.split('/').last;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppStyles.cardDecoration(),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.picture_as_pdf,
                  color: AppColors.primary, size: 28),
            ),
            title: Text(fileName,
                style:
                    AppFonts.bodyLarge.copyWith(color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            subtitle: FutureBuilder<String>(
              future: PdfService.getFileSize(file),
              builder: (_, snapshot) => Text(snapshot.data ?? '...',
                  style: AppFonts.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.textSecondary),
              onPressed: () => _deletePdf(file),
            ),
            onTap: () => _openPdf(file),
          ),
        );
      },
    );
  }
}
