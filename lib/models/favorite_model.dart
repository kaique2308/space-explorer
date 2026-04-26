class FavoriteModel {
  final String id;
  final String title;
  final String imageUrl;
  final String date;
  final String explanation;
  final DateTime savedAt;

  FavoriteModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.date,
    required this.explanation,
    required this.savedAt,
  });

  factory FavoriteModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return FavoriteModel(
      id: docId,
      title: data['title'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      date: data['date'] ?? '',
      explanation: data['explanation'] ?? '',
      savedAt: data['savedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['savedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'date': date,
      'explanation': explanation,
      'savedAt': savedAt.millisecondsSinceEpoch,
    };
  }
}
