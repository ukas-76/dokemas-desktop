class ReviewModel {
  final int id;
  final int userId;
  final int destinationId;
  final double rating;
  final String comment;
  final String userName;
  final String? userEmail;
  final String destinationName;
  final String? reportReason;
  final String? status;
  final String? createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.destinationId,
    required this.rating,
    required this.comment,
    required this.userName,
    this.userEmail,
    required this.destinationName,
    this.reportReason,
    this.status,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final userObj = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : null;
    final destObj = json['destination'] is Map<String, dynamic>
        ? json['destination'] as Map<String, dynamic>
        : null;

    double parsedRating = 0.0;
    if (json['rating'] != null) {
      parsedRating = json['rating'] is num
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating'].toString()) ?? 0.0;
    }

    return ReviewModel(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: json['user_id'] is num
          ? (json['user_id'] as num).toInt()
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      destinationId: json['destination_id'] is num
          ? (json['destination_id'] as num).toInt()
          : int.tryParse(json['destination_id']?.toString() ?? '0') ?? 0,
      rating: parsedRating,
      comment: (json['comment'] ?? json['content'] ?? json['review'] ?? '').toString(),
      userName: (userObj?['name'] ?? json['user_name'] ?? 'Pengunjung').toString(),
      userEmail: userObj?['email']?.toString(),
      destinationName: (destObj?['name'] ?? json['destination_name'] ?? 'Destinasi #${json['destination_id'] ?? '-'}').toString(),
      reportReason: (json['report_reason'] ?? json['reason'])?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  bool get isLowRating => rating > 0 && rating <= 3.0;

  String get formattedDate {
    if (createdAt == null || createdAt!.isEmpty) return '-';
    final parsed = DateTime.tryParse(createdAt!);
    if (parsed == null) return createdAt!;
    final local = parsed.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}, '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class PaginatedReviewsResponse {
  final List<ReviewModel> reviews;
  final int currentPage;
  final int lastPage;
  final int total;

  const PaginatedReviewsResponse({
    required this.reviews,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}
