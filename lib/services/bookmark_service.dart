import 'package:hive/hive.dart';

class BookmarkEntry {
  final String filePath;
  final String fileName;
  final int pageNumber;
  final DateTime createdAt;

  const BookmarkEntry({
    required this.filePath,
    required this.fileName,
    required this.pageNumber,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'filePath': filePath,
        'fileName': fileName,
        'pageNumber': pageNumber,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory BookmarkEntry.fromJson(Map<String, dynamic> json) => BookmarkEntry(
        filePath: json['filePath'] as String,
        fileName: json['fileName'] as String,
        pageNumber: json['pageNumber'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );
}

class BookmarkService {
  BookmarkService._();

  static const String _boxName = 'bookmarks_box';

  static Future<Box> _getBox() async {
    return await Hive.openBox(_boxName);
  }

  /// Add a bookmark
  static Future<void> addBookmark(BookmarkEntry entry) async {
    final box = await _getBox();
    final key = '${entry.filePath}_${entry.pageNumber}';
    await box.put(key, entry.toJson());
  }

  /// Remove a bookmark
  static Future<void> removeBookmark(String filePath, int pageNumber) async {
    final box = await _getBox();
    final key = '${filePath}_$pageNumber';
    await box.delete(key);
  }

  /// Check if a page is bookmarked
  static Future<bool> isBookmarked(String filePath, int pageNumber) async {
    final box = await _getBox();
    final key = '${filePath}_$pageNumber';
    return box.containsKey(key);
  }

  /// Get all bookmarks for a file
  static Future<List<BookmarkEntry>> getBookmarks(String filePath) async {
    final box = await _getBox();
    final bookmarks = <BookmarkEntry>[];
    for (final key in box.keys) {
      if (key.toString().startsWith(filePath)) {
        final json = box.get(key) as Map?;
        if (json != null) {
          bookmarks.add(BookmarkEntry.fromJson(Map<String, dynamic>.from(json)));
        }
      }
    }
    bookmarks.sort((a, b) => a.pageNumber.compareTo(b.pageNumber));
    return bookmarks;
  }

  /// Get all bookmarks
  static Future<List<BookmarkEntry>> getAllBookmarks() async {
    final box = await _getBox();
    final bookmarks = <BookmarkEntry>[];
    for (final key in box.keys) {
      final json = box.get(key) as Map?;
      if (json != null) {
        bookmarks.add(BookmarkEntry.fromJson(Map<String, dynamic>.from(json)));
      }
    }
    bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookmarks;
  }
}
