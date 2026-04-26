class ApodModel {
  final String title;
  final String explanation;
  final String url;
  final String? hdUrl;
  final String date;
  final String mediaType;
  final String? copyright;

  ApodModel({
    required this.title,
    required this.explanation,
    required this.url,
    this.hdUrl,
    required this.date,
    required this.mediaType,
    this.copyright,
  });

  factory ApodModel.fromJson(Map<String, dynamic> json) {
    return ApodModel(
      title: json['title'] ?? '',
      explanation: json['explanation'] ?? '',
      url: json['url'] ?? '',
      hdUrl: json['hdurl'],
      date: json['date'] ?? '',
      mediaType: json['media_type'] ?? 'image',
      copyright: json['copyright'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'explanation': explanation,
      'url': url,
      'hdUrl': hdUrl,
      'date': date,
      'mediaType': mediaType,
      'copyright': copyright,
    };
  }

  bool get isImage => mediaType == 'image';

  String get formattedDate {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        final months = [
          '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
        ];
        final month = int.parse(parts[1]);
        return '${parts[2]} ${months[month]} ${parts[0]}';
      }
    } catch (_) {}
    return date;
  }
}
