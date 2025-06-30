class TranslationRecord {
  final String id;
  final String originalText;
  final String translatedText;
  final String? imagePath;
  final DateTime createdAt;
  final bool isFavorite;

  TranslationRecord({
    required this.id,
    required this.originalText,
    required this.translatedText,
    this.imagePath,
    required this.createdAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalText': originalText,
      'translatedText': translatedText,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory TranslationRecord.fromJson(Map<String, dynamic> json) {
    return TranslationRecord(
      id: json['id'],
      originalText: json['originalText'],
      translatedText: json['translatedText'],
      imagePath: json['imagePath'],
      createdAt: DateTime.parse(json['createdAt']),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  TranslationRecord copyWith({
    String? id,
    String? originalText,
    String? translatedText,
    String? imagePath,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return TranslationRecord(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      translatedText: translatedText ?? this.translatedText,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
} 