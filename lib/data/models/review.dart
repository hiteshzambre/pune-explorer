class Review {
  final String id;
  final String destinationId;
  final String authorName;
  final String authorAvatar;
  final double rating;
  final String comment;
  final String date;
  final int helpfulCount;

  const Review({
    required this.id,
    required this.destinationId,
    required this.authorName,
    required this.authorAvatar,
    required this.rating,
    required this.comment,
    required this.date,
    this.helpfulCount = 0,
  });

  Review copyWith({int? helpfulCount}) => Review(
        id: id,
        destinationId: destinationId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        rating: rating,
        comment: comment,
        date: date,
        helpfulCount: helpfulCount ?? this.helpfulCount,
      );

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        destinationId: json['destinationId'] as String? ?? '',
        authorName: json['authorName'] as String? ?? json['name'] as String? ?? 'Traveler',
        authorAvatar: json['authorAvatar'] as String? ?? json['avatar'] as String? ?? 'PT',
        rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
        comment: json['comment'] as String? ?? json['text'] as String? ?? '',
        date: json['date'] as String? ?? 'August 2026',
        helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'destinationId': destinationId,
        'authorName': authorName,
        'authorAvatar': authorAvatar,
        'rating': rating,
        'comment': comment,
        'date': date,
        'helpfulCount': helpfulCount,
      };
}
