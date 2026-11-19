import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/dashboard_model.dart';
import '../models/destination_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl =
      'https://porto-backend-dokemas.rryxja.easypanel.host/api';

  // Session state untuk Super Admin yang sedang login
  static String? authToken;
  static UserModel? currentUser;

  static bool get isAuthenticated =>
      authToken != null && authToken!.isNotEmpty;

  static File? _sessionFile() {
    try {
      final baseDir = Platform.environment['LOCALAPPDATA'] ??
          Platform.environment['APPDATA'] ??
          Platform.environment['HOME'];
      if (baseDir == null || baseDir.isEmpty) return null;
      return File('$baseDir${Platform.pathSeparator}dokemas_dekstop${Platform.pathSeparator}session.json');
    } catch (_) {
      return null;
    }
  }

  static Future<void> _saveSession(String token) async {
    try {
      final file = _sessionFile();
      if (file == null) return;
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsString(jsonEncode({'token': token}));
    } catch (_) {}
  }

  static Future<void> _clearSession() async {
    try {
      final file = _sessionFile();
      if (file != null && await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Memulihkan sesi login terakhir saat aplikasi desktop dibuka kembali
  static Future<void> restoreSession() async {
    try {
      final file = _sessionFile();
      if (file == null || !await file.exists()) return;
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic> && decoded['token'] != null) {
        final token = decoded['token'].toString();
        if (token.isNotEmpty) {
          authToken = token;
          await ApiService().getMe();
        }
      }
    } catch (_) {
      authToken = null;
      currentUser = null;
      await _clearSession();
    }
  }

  Map<String, String> _headers({bool withJson = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (withJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (authToken != null && authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $authToken';
    }
    return headers;
  }

  String _extractErrorMessage(http.Response response, String fallback) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['errors'] is Map<String, dynamic>) {
          final errors = decoded['errors'] as Map<String, dynamic>;
          final messages = <String>[];
          for (final entry in errors.entries) {
            if (entry.value is List && (entry.value as List).isNotEmpty) {
              messages.add((entry.value as List).first.toString());
            } else if (entry.value != null) {
              messages.add(entry.value.toString());
            }
          }
          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }
        if (decoded['message'] != null &&
            decoded['message'].toString().isNotEmpty) {
          return decoded['message'].toString();
        }
      }
    } catch (_) {}
    return '$fallback (Status: ${response.statusCode})';
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  AUTHENTIKASI SUPER ADMIN & RESET PASSWORD
  // ═══════════════════════════════════════════════════════════════════════

  /// Login Super Admin ke POST /api/login dan simpan token + profil
  Future<UserModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email.trim(),
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      String? token;
      Map<String, dynamic>? userMap;

      if (decoded is Map<String, dynamic>) {
        final dataObj = decoded['data'] is Map<String, dynamic>
            ? decoded['data'] as Map<String, dynamic>
            : null;

        token = (decoded['token'] ??
                decoded['access_token'] ??
                dataObj?['token'] ??
                dataObj?['access_token'])
            ?.toString();

        if (decoded['user'] is Map<String, dynamic>) {
          userMap = decoded['user'] as Map<String, dynamic>;
        } else if (dataObj?['user'] is Map<String, dynamic>) {
          userMap = dataObj!['user'] as Map<String, dynamic>;
        }
      }

      if (token == null || token.isEmpty) {
        throw ApiException(
          'Token autentikasi tidak ditemukan pada respons server.',
          statusCode: response.statusCode,
        );
      }

      authToken = token;

      UserModel user;
      if (userMap != null) {
        user = UserModel.fromJson(userMap);
      } else {
        user = await getMe();
      }

      currentUser = user;
      await _saveSession(token);
      return user;
    } else if (response.statusCode == 401) {
      throw ApiException(
        _extractErrorMessage(response, 'Email atau password salah.'),
        statusCode: 401,
      );
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Login gagal dilakukan'),
        statusCode: response.statusCode,
      );
    }
  }

  /// Mengirim kode OTP lupa password via POST /api/forgot-password
  Future<String> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/forgot-password'),
      headers: _headers(),
      body: jsonEncode({'email': email.trim()}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          return decoded['message'].toString();
        }
      } catch (_) {}
      return 'Kode OTP reset password telah dikirim ke email Anda.';
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal mengirim permintaan reset password'),
        statusCode: response.statusCode,
      );
    }
  }

  /// Reset password dengan OTP via POST /api/reset-password
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String password,
    String? passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: _headers(),
      body: jsonEncode({
        'email': email.trim(),
        'otp': otp.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation ?? password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['message'] != null) {
          return decoded['message'].toString();
        }
      } catch (_) {}
      return 'Kata sandi berhasil diperbarui. Silakan login.';
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal mereset kata sandi'),
        statusCode: response.statusCode,
      );
    }
  }

  /// Mengambil data user yang sedang login dari GET /api/me
  Future<UserModel> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: _headers(withJson: false),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> userJson =
          (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
              ? decoded['data'] as Map<String, dynamic>
              : (decoded is Map<String, dynamic> && decoded['user'] is Map<String, dynamic>)
                  ? decoded['user'] as Map<String, dynamic>
                  : decoded as Map<String, dynamic>;

      final user = UserModel.fromJson(userJson);
      currentUser = user;
      return user;
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Sesi tidak valid atau telah berakhir'),
        statusCode: response.statusCode,
      );
    }
  }

  /// Logout dari POST /api/logout dan bersihkan sesi lokal
  Future<void> logout() async {
    try {
      if (authToken != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: _headers(withJson: false),
        );
      }
    } catch (_) {
    } finally {
      authToken = null;
      currentUser = null;
      await _clearSession();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  DASHBOARD & LAPORAN AGREGASI
  // ═══════════════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> getDashboardRaw() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/dashboard'),
        headers: _headers(withJson: false),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (_) {}
    return {};
  }

  Future<DashboardDataBundle> getDashboardBundle() async {
    final results = await Future.wait([
      getDashboardRaw(),
      getDestinationsPaginated(page: 1),
      getCategories(),
      getFacilities().catchError((_) => <FacilityModel>[]),
      getUsers(page: 1).catchError(
        (_) => const PaginatedUsersResponse(users: [], currentPage: 1, lastPage: 1, total: 0),
      ),
      getReviews(page: 1).catchError(
        (_) => const PaginatedReviewsResponse(reviews: [], currentPage: 1, lastPage: 1, total: 0),
      ),
    ]);

    return DashboardDataBundle.compose(
      rawDashboard: results[0] as Map<String, dynamic>,
      destinationsRes: results[1] as PaginatedDestinationsResponse,
      categories: results[2] as List<CategoryModel>,
      facilities: results[3] as List<FacilityModel>,
      usersRes: results[4] as PaginatedUsersResponse,
      reviewsRes: results[5] as PaginatedReviewsResponse,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  MANAJEMEN USER & MITRA (ADMIN)
  // ═══════════════════════════════════════════════════════════════════════

  /// Mengambil daftar user & mitra riil dari GET /api/admin/users
  Future<PaginatedUsersResponse> getUsers({
    String? search,
    String? role,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }
    if (role != null && role.isNotEmpty && role != 'all') {
      queryParams['role'] = role;
    }

    final uri = Uri.parse('$baseUrl/admin/users').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
      headers: _headers(withJson: false),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> rawList = [];
      int currentPage = page;
      int lastPage = 1;
      int total = 0;

      if (decoded is List) {
        rawList = decoded;
        total = decoded.length;
      } else if (decoded is Map<String, dynamic>) {
        final dynamic dataField = decoded['data'];
        if (dataField is List) {
          rawList = dataField;
          currentPage = (decoded['current_page'] as num?)?.toInt() ?? page;
          lastPage = (decoded['last_page'] as num?)?.toInt() ?? 1;
          total = (decoded['total'] as num?)?.toInt() ?? rawList.length;
        } else if (dataField is Map<String, dynamic> && dataField['data'] is List) {
          rawList = dataField['data'] as List;
          currentPage = (dataField['current_page'] as num?)?.toInt() ?? page;
          lastPage = (dataField['last_page'] as num?)?.toInt() ?? 1;
          total = (dataField['total'] as num?)?.toInt() ?? rawList.length;
        }
      }

      final users = rawList
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList();

      return PaginatedUsersResponse(
        users: users,
        currentPage: currentPage,
        lastPage: lastPage,
        total: total == 0 ? users.length : total,
      );
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal memuat data user & mitra'),
        statusCode: response.statusCode,
      );
    }
  }

  /// Mengambil detail user berdasarkan ID dari GET /api/admin/users/{id}
  Future<UserModel> getUserDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/$id'),
      headers: _headers(withJson: false),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data =
          (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
              ? decoded['data'] as Map<String, dynamic>
              : decoded as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal memuat detail user'),
        statusCode: response.statusCode,
      );
    }
  }

  /// Menambahkan user/mitra baru melalui POST /api/admin/users
  Future<UserModel> createUser(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users'),
      headers: _headers(),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data =
          (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
              ? decoded['data'] as Map<String, dynamic>
              : (decoded is Map<String, dynamic> && decoded['user'] is Map<String, dynamic>)
                  ? decoded['user'] as Map<String, dynamic>
                  : decoded as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal menambahkan user/mitra baru'),
        statusCode: response.statusCode,
      );
    }
  }

  /// Memperbarui data/role user atau mitra melalui PUT /api/admin/users/{id}
  Future<UserModel> updateUser(int id, Map<String, dynamic> payload) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$id'),
      headers: _headers(),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data =
          (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
              ? decoded['data'] as Map<String, dynamic>
              : (decoded is Map<String, dynamic> && decoded['user'] is Map<String, dynamic>)
                  ? decoded['user'] as Map<String, dynamic>
                  : decoded as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal memperbarui data user/mitra'),
        statusCode: response.statusCode,
      );
    }
  }

  /// Menghapus user/mitra melalui DELETE /api/admin/users/{id}
  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/users/$id'),
      headers: _headers(withJson: false),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal menghapus user/mitra'),
        statusCode: response.statusCode,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  KATEGORI & FASILITAS (CRUD ADMIN)
  // ═══════════════════════════════════════════════════════════════════════

  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: _headers(withJson: false),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> body;

      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        body = decoded['data'];
      } else if (decoded is List) {
        body = decoded;
      } else {
        body = [];
      }

      return body.map((item) => CategoryModel.fromJson(item)).toList();
    } else {
      throw ApiException(
        'Gagal memuat data kategori (Status: ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/categories'),
      headers: _headers(),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data =
          (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
              ? decoded['data'] as Map<String, dynamic>
              : decoded as Map<String, dynamic>;
      return CategoryModel.fromJson(data);
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal menambah kategori'),
        statusCode: response.statusCode,
      );
    }
  }

  Future<CategoryModel> updateCategory(int id, Map<String, dynamic> payload) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/categories/$id'),
      headers: _headers(),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data =
          (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
              ? decoded['data'] as Map<String, dynamic>
              : decoded as Map<String, dynamic>;
      return CategoryModel.fromJson(data);
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal memperbarui kategori'),
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/categories/$id'),
      headers: _headers(withJson: false),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal menghapus kategori'),
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<FacilityModel>> getFacilities() async {
    final response = await http.get(
      Uri.parse('$baseUrl/facilities'),
      headers: _headers(withJson: false),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> body = decoded is List
          ? decoded
          : (decoded is Map<String, dynamic> && decoded['data'] is List)
              ? decoded['data'] as List
              : [];
      return body.whereType<Map<String, dynamic>>().map(FacilityModel.fromJson).toList();
    } else {
      throw ApiException(
        'Gagal memuat fasilitas (Status: ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  DESTINASI & PENGINAPAN (CRUD ADMIN)
  // ═══════════════════════════════════════════════════════════════════════

  Future<PaginatedDestinationsResponse> getDestinationsPaginated({
    String? categorySlug,
    String? search,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
    };
    if (categorySlug != null && categorySlug.isNotEmpty && categorySlug != 'all') {
      queryParams['category'] = categorySlug;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl/destinations').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
      headers: _headers(withJson: false),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> body = [];
      int currentPage = page;
      int lastPage = 1;
      int total = 0;

      if (decoded is Map<String, dynamic> && decoded['data'] is List) {
        body = decoded['data'] as List;
        currentPage = (decoded['current_page'] as num?)?.toInt() ?? page;
        lastPage = (decoded['last_page'] as num?)?.toInt() ?? 1;
        total = (decoded['total'] as num?)?.toInt() ?? body.length;
      } else if (decoded is List) {
        body = decoded;
        total = decoded.length;
      }

      final items = body
          .whereType<Map<String, dynamic>>()
          .map(DestinationModel.fromJson)
          .toList();

      return PaginatedDestinationsResponse(
        destinations: items,
        currentPage: currentPage,
        lastPage: lastPage,
        total: total == 0 ? items.length : total,
      );
    } else {
      throw ApiException(
        'Gagal memuat destinasi (Status: ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<DestinationModel>> getDestinations({
    String? categorySlug,
    String? search,
  }) async {
    final res = await getDestinationsPaginated(
      categorySlug: categorySlug,
      search: search,
      page: 1,
    );
    return res.destinations;
  }

  Future<DestinationModel> getDestinationDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/destinations/$id'),
      headers: _headers(withJson: false),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data =
          (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
              ? decoded['data'] as Map<String, dynamic>
              : decoded as Map<String, dynamic>;

      return DestinationModel.fromJson(data);
    } else {
      throw ApiException(
        'Gagal mengambil detail destinasi',
        statusCode: response.statusCode,
      );
    }
  }

  Future<DestinationModel> createDestination(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/destinations'),
      headers: _headers(),
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final Map<String, dynamic> data =
          (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
              ? decoded['data'] as Map<String, dynamic>
              : decoded as Map<String, dynamic>;
      return DestinationModel.fromJson(data);
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal menambahkan destinasi baru'),
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> updateDestination(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/destinations/$id'),
      headers: _headers(),
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal memperbarui data destinasi'),
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> deleteDestination(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/destinations/$id'),
      headers: _headers(withJson: false),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal menghapus destinasi'),
        statusCode: response.statusCode,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════
  //  MODERASI ULASAN (ADMIN)
  // ═══════════════════════════════════════════════════════════════════════

  Future<PaginatedReviewsResponse> getReviews({
    String? search,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl/admin/reviews').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(
      uri,
      headers: _headers(withJson: false),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> rawList = [];
      int currentPage = page;
      int lastPage = 1;
      int total = 0;

      if (decoded is List) {
        rawList = decoded;
        total = decoded.length;
      } else if (decoded is Map<String, dynamic>) {
        final dynamic dataField = decoded['data'];
        if (dataField is List) {
          rawList = dataField;
          currentPage = (decoded['current_page'] as num?)?.toInt() ?? page;
          lastPage = (decoded['last_page'] as num?)?.toInt() ?? 1;
          total = (decoded['total'] as num?)?.toInt() ?? rawList.length;
        } else if (dataField is Map<String, dynamic> && dataField['data'] is List) {
          rawList = dataField['data'] as List;
          currentPage = (dataField['current_page'] as num?)?.toInt() ?? page;
          lastPage = (dataField['last_page'] as num?)?.toInt() ?? 1;
          total = (dataField['total'] as num?)?.toInt() ?? rawList.length;
        }
      }

      final reviews = rawList
          .whereType<Map<String, dynamic>>()
          .map(ReviewModel.fromJson)
          .toList();

      return PaginatedReviewsResponse(
        reviews: reviews,
        currentPage: currentPage,
        lastPage: lastPage,
        total: total == 0 ? reviews.length : total,
      );
    } else {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal memuat daftar ulasan'),
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> deleteReview(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/reviews/$id'),
      headers: _headers(withJson: false),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException(
        _extractErrorMessage(response, 'Gagal menghapus ulasan'),
        statusCode: response.statusCode,
      );
    }
  }
}
