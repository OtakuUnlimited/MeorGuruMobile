import 'api_client.dart';

class ContentService {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> fetchAllGurus() async {
    final response = await _client.get('guru-list');
    return List<dynamic>.from(response);
  }

  Future<List<dynamic>> fetchOnlinePujas() async {
    final response = await _client.get('online-pujas/list');
    return response['data'] ?? [];
  }

  Future<List<dynamic>> fetchCategories() async {
    final response = await _client.get('categories');
    return response['data'] ?? [];
  }

  Future<List<dynamic>> fetchBlogs() async {
    final response = await _client.get('latest_blogs');
    return response['data'] ?? [];
  }

  Future<List<dynamic>> fetchServices() async {
    final response = await _client.get('all-service');
    return response['data'] ?? [];
  }

  Future<dynamic> fetchPatroData() async {
    return await _client.get('get-patro');
  }

  Future<dynamic> fetchGuruDetails(String slug) async {
    return await _client.get('guru-details/$slug');
  }

  // =========================
  // Categories
  // =========================

 Future<List<dynamic>> fetchTopDecorations() async {
  final response = await _client.get('categories/decoration');

  if (response is Map<String, dynamic>) {
    final data = response['data'];

    if (data is Map<String, dynamic>) {
      final services = data['services'];

      if (services is List) {
        return List<dynamic>.from(services);
      }
    }
  }

  return [];
}

 Future<List<dynamic>> fetchPopularVenues() async {
  final response = await _client.get('categories/venue');

  final data = response['data'];

  if (data == null || data['services'] == null) {
    return [];
  }

  return data['services'];
}
  Future<dynamic> servicesDetails(String slug) async {
    return await _client.get('categories/$slug');
  }
  Future<dynamic> serviceDetails(String slug) async {
    return await _client.get('service-details/$slug');
  }
}