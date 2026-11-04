import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class ApiService {
  static const String baseUrl =
      'https://porto-backend-dokemas.rryxja.easypanel.host/api';

  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> body;

      // Mengecek apakah JSON berbentuk Map dengan key 'data' atau langsung berjenis List
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        body = decoded['data'];
      } else if (decoded is List) {
        body = decoded;
      } else {
        body = [];
      }

      return body.map((item) => CategoryModel.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat data kategori');
    }
  }
}
