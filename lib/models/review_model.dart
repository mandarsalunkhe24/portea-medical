import 'dart:convert';

class Review {
  final String id;
  final String professionalId;
  final String userName;
  final double rating;
  final DateTime date;
  final List<String> tags; // 'Punctual', 'Professional', 'Caring', 'Gentle', 'Thorough'
  final String comment;
  final String serviceRendered;

  Review({
    required this.id,
    required this.professionalId,
    required this.userName,
    required this.rating,
    required this.date,
    required this.tags,
    required this.comment,
    required this.serviceRendered,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'professionalId': professionalId,
      'userName': userName,
      'rating': rating,
      'date': date.toIso8601String(),
      'tags': tags,
      'comment': comment,
      'serviceRendered': serviceRendered,
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      professionalId: map['professionalId'] ?? '',
      userName: map['userName'] ?? 'Verified Patient',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      tags: (map['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList() ??
          [],
      comment: map['comment'] ?? '',
      serviceRendered: map['serviceRendered'] ?? 'Home Healthcare',
    );
  }

  String toJson() => json.encode(toMap());
  factory Review.fromJson(String source) => Review.fromMap(json.decode(source));
}
