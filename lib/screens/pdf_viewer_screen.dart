import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_fonts.dart';
import '../core/theme/theme_provider.dart';
import '../services/bookmark_service.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final File pdfFile;
  final int? initialPage;

  const PdfViewerScreen({super.key, required this.pdfFile, this.initialPage});

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 0;
  bool _isBookmarked = false;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _checkBookmark();
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  Future<void> _checkBookmark() async {
    final bookmarked = await BookmarkService.isBookmarked(widget.pdfFile.path, _currentPage);
    if (mounted) setState(() => _isBookmarked = bookmarked);
  }

  Future<void> _toggleBookmark() async {
    if (_isBookmarked) {
      await BookmarkService.removeBookmark(widget.pdfFile.path, _currentPage);
    } else {
      await BookmarkService.addBookmark(BookmarkEntry(
        filePath: widget.pdfFile.path,
        fileName: widget.pdfFile.path.split('/').last,
        pageNumber: _currentPage,
        createdAt: DateTime.now(),
      ));
    }
    setState(() => _isBookmarked = !_isBookmarked);
  }

  void _showBookmarks() async {
    final bookmarks = await BookmarkService.getBookmarks(widget.pdfFile.path);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.7,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bookmarks', style: AppFonts.h3),
                  Text('${bookmarks.length} bookmark(s)', style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: bookmarks.isEmpty
                  ? Center(child: Text('No bookmarks yet', style: AppFonts.bodyMedium.copyWith(color: AppColors.textHint)))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: bookmarks.length,
                      itemBuilder: (_, i) {
                        final bm = bookmarks[i];
                        return ListTile(
                          leading: const Icon(Icons.bookmark, color: AppColors.primary),
                          title: Text('Page ${bm.pageNumber}', style: AppFonts.bodyMedium),
                          subtitle: Text(bm.fileName, style: AppFonts.bodySmall.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textSecondary),
                            onPressed: () async {
                              await BookmarkService.removeBookmark(bm.filePath, bm.pageNumber);
                              if (!mounted) return;
                              if (ctx.mounted) Navigator.pop(ctx);
                              _checkBookmark();
                            },
                          ),
                          onTap: () {
                            _pdfController.jumpToPage(bm.pageNumber);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
      appBar: AppBar(
        title: Text(widget.pdfFile.path.split('/').last, style: AppFonts.bodyLarge, overflow: TextOverflow.ellipsis),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? AppColors.accent : null),
            onPressed: _toggleBookmark,
            tooltip: 'Bookmark',
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showBookmarks,
            tooltip: 'Bookmarks',
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.file(
            widget.pdfFile,
            key: _pdfViewerKey,
            controller: _pdfController,
            canShowTextSelectionMenu: true,
            initialPageNumber: widget.initialPage ?? 1,
            onDocumentLoaded: (details) {
              setState(() {
                _isLoading = false;
                _totalPages = details.document.pages.count;
              });
            },
            onPageChanged: (details) {
              setState(() => _currentPage = details.newPageNumber);
              _checkBookmark();
            },
          ),
          if (_isLoading)
            const Center(
              child: SpinKitFadingCircle(color: AppColors.primary, size: 48),
            ),
        ],
      ),
      bottomNavigationBar: !_isLoading
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _currentPage > 1 ? () => _pdfController.previousPage() : null,
                    ),
                    Text('$_currentPage / $_totalPages', style: AppFonts.bodyMedium.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _currentPage < _totalPages ? () => _pdfController.nextPage() : null,
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
