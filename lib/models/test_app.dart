import 'dart:typed_data';

class TestApp {
  final String name;
  final String packageName;
  final List<DateTime> checkInDates;
  final DateTime addedDate;
  final Uint8List? icon;

  TestApp({
    required this.name,
    required this.packageName,
    required this.checkInDates,
    required this.addedDate,
    this.icon,
  });

  int get testDays => checkInDates.length;

  bool get isCheckInToday {
    final now = DateTime.now();
    return checkInDates.any((d) =>
        d.year == now.year && d.month == now.month && d.day == now.day);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'packageName': packageName,
      'checkInDates': checkInDates.map((d) => d.toIso8601String()).toList(),
      'addedDate': addedDate.toIso8601String(),
      'icon': icon,
    };
  }

  factory TestApp.fromMap(Map<dynamic, dynamic> map) {
    return TestApp(
      name: map['name'] as String,
      packageName: map['packageName'] as String,
      checkInDates: (map['checkInDates'] as List)
          .map((d) => DateTime.parse(d as String))
          .toList(),
      addedDate: DateTime.parse(map['addedDate'] as String),
      icon: map['icon'] as Uint8List?,
    );
  }

  TestApp copyWith({
    String? name,
    String? packageName,
    List<DateTime>? checkInDates,
    DateTime? addedDate,
    Uint8List? icon,
  }) {
    return TestApp(
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      checkInDates: checkInDates ?? this.checkInDates,
      addedDate: addedDate ?? this.addedDate,
      icon: icon ?? this.icon,
    );
  }
}
