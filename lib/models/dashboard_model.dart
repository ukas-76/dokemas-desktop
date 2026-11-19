import 'category_model.dart';
import 'destination_model.dart';
import 'review_model.dart';
import 'user_model.dart';

class DashboardDataBundle {
  final int totalDestinations;
  final int totalCategories;
  final int totalFacilities;
  final int totalUsers;
  final int totalMitra;
  final int totalReviews;
  final int popularDestinations;
  final double averageRating;
  final List<CategoryModel> categories;
  final List<DestinationModel> destinations;
  final List<UserModel> recentUsers;
  final List<ReviewModel> recentReviews;
  final Map<String, dynamic> rawDashboard;

  const DashboardDataBundle({
    required this.totalDestinations,
    required this.totalCategories,
    required this.totalFacilities,
    required this.totalUsers,
    required this.totalMitra,
    required this.totalReviews,
    required this.popularDestinations,
    required this.averageRating,
    required this.categories,
    required this.destinations,
    required this.recentUsers,
    required this.recentReviews,
    required this.rawDashboard,
  });

  static int? _pickInt(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v is num) return v.toInt();
      if (v != null) {
        final parsed = int.tryParse(v.toString());
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  factory DashboardDataBundle.compose({
    required Map<String, dynamic> rawDashboard,
    required PaginatedDestinationsResponse destinationsRes,
    required List<CategoryModel> categories,
    required List<FacilityModel> facilities,
    required PaginatedUsersResponse usersRes,
    required PaginatedReviewsResponse reviewsRes,
  }) {
    final statsMap = rawDashboard['stats'] is Map<String, dynamic>
        ? rawDashboard['stats'] as Map<String, dynamic>
        : (rawDashboard['data'] is Map<String, dynamic>
            ? rawDashboard['data'] as Map<String, dynamic>
            : rawDashboard);

    final destinations = destinationsRes.destinations;
    final users = usersRes.users;
    final reviews = reviewsRes.reviews;

    final int totalDest = _pickInt(statsMap, ['total_destinations', 'destinations_count', 'destinations']) ??
        destinationsRes.total;
    final int totalCat = _pickInt(statsMap, ['total_categories', 'categories_count', 'categories']) ??
        categories.length;
    final int totalFac = _pickInt(statsMap, ['total_facilities', 'facilities_count', 'facilities']) ??
        facilities.length;
    final int totalUsr = _pickInt(statsMap, ['total_users', 'users_count', 'users']) ??
        usersRes.total;
    final int totalMtr = _pickInt(statsMap, ['total_mitra', 'mitra_count', 'partners_count']) ??
        users.where((u) => u.isMitra).length;
    final int totalRev = _pickInt(statsMap, ['total_reviews', 'reviews_count', 'reviews']) ??
        reviewsRes.total;
    final int popularCount = destinations.where((d) => d.isPopular).length;

    double avgRating = 0.0;
    final rated = destinations.where((d) => d.ratingAvg > 0).toList();
    if (rated.isNotEmpty) {
      avgRating = rated.map((d) => d.ratingAvg).reduce((a, b) => a + b) / rated.length;
    } else if (reviews.isNotEmpty) {
      avgRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    }

    return DashboardDataBundle(
      totalDestinations: totalDest,
      totalCategories: totalCat,
      totalFacilities: totalFac,
      totalUsers: totalUsr,
      totalMitra: totalMtr,
      totalReviews: totalRev,
      popularDestinations: popularCount,
      averageRating: avgRating,
      categories: categories,
      destinations: destinations,
      recentUsers: users,
      recentReviews: reviews,
      rawDashboard: rawDashboard,
    );
  }
}
