import 'api_client.dart';
import 'cache_service.dart';
import 'cache_keys.dart';
import 'package:flutter/foundation.dart';


class ContentService {
  final ApiClient _client = ApiClient();

  Future<List<dynamic>> fetchAllGurus() async {
  try {
    final response = await _client.get('guru-list');

    final data = List<dynamic>.from(response);

    await CacheService.save(
      CacheKeys.gurus,
      data.take(20).toList(),
    );
  debugPrint('GET GURUS RESPONSE: $response');
    return data;
  } catch (e) {
    return CacheService.getList(
      CacheKeys.gurus,
    );
  }
}

 Future<List<dynamic>> fetchOnlinePujas() async {
  try {
    final response =
        await _client.get('online-pujas/list');

    final data = response['data'] ?? [];

    await CacheService.save(
      CacheKeys.onlinePujas,
      data.take(20).toList(),
    );

    return data;
  } catch (e) {
    return CacheService.getList(
      CacheKeys.onlinePujas,
    );
  }
}

Future<dynamic> fetchPujaDetails(String slug) async {
  return await _client.get('online-puja/$slug');
}

Future<List<Map<String, dynamic>>> fetchEvents() async {
  try {
    final response = await _client.get('events/list');

    final data = List<Map<String, dynamic>>.from(
      response['data'] ?? [],
    );

    await CacheService.save(
      CacheKeys.events,
      data.take(20).toList(),
    );

    return data;
  } catch (e) {
    return List<Map<String, dynamic>>.from(
      await CacheService.getList(CacheKeys.events),
    );
  }
}

Future<dynamic> fetchEventDetails(String slug) async {
  return await _client.get('event/$slug');
}



//Astrology Services
Future<List<dynamic>> fetchAstrologyServices() async {
  try {
    final response =
        await _client.get('astrology/list');

    final data = response['data'] ?? [];

    await CacheService.save(
      CacheKeys.astrologyServices,
      data.take(20).toList(),
    );

    return data;
  } catch (e) {
    return CacheService.getList(
      CacheKeys.astrologyServices,
    );
  }
}

Future<dynamic> fetchAstrologyDetails(String slug) async {
  return await _client.get('astrology/$slug');
}



//categories
 Future<List<dynamic>> getCachedCategories() async {
  return await CacheService.getList(
    CacheKeys.categories,
  );
}

Future<List<dynamic>> refreshCategories() async {
  final response = await _client.get('categories');

  final data = response['data'] ?? [];

  await CacheService.save(
    CacheKeys.categories,
    data,
  );

  return data;
}


//blogs

  Future<List<dynamic>> fetchBlogs() async {
  try {
    final response =
        await _client.get('latest_blogs');

    final data = response['data'] ?? [];

    await CacheService.save(
      CacheKeys.blogs,
      data.take(10).toList(),
    );

    return data;
  } catch (e) {
    return CacheService.getList(
      CacheKeys.blogs,
    );
  }
}

Future<List<Map<String, dynamic>>> getBlogs() async {
    try {
      final response = await _client.get('blogs');

      if (response['status'] == 200 &&
          response['data'] is List) {
        return List<Map<String, dynamic>>.from(
          response['data'],
        );
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> fetchBlogDetails(String slug) async {
  final response = await _client.get('blog-details/$slug');

  if (response['status'] == 200) {
    return response['data'];
  }

  throw Exception('Failed to load blog');
}

//services
 Future<List<dynamic>> fetchServices() async {
  try {
    final response =
        await _client.get('all-service');

    final data = response['data'] ?? [];

    await CacheService.save(
      CacheKeys.services,
      data.take(20).toList(),
    );

    return data;
  } catch (e) {
    return CacheService.getList(
      CacheKeys.services,
    );
  }
}


//patro

  Future<List<Map<String, dynamic>>> fetchPatroData() async {
  final response = await _client.get(
    'get-patro',
  );

  if (response['status'] == 200) {
    return List<Map<String, dynamic>>.from(
      response['data'] ?? [],
    );
  }

  throw Exception('Failed to load Patro');
}

//guru
  Future<dynamic> fetchGuruDetails(String slug) async {
    return await _client.get('guru-details/$slug');
  }

  // =========================
  // Categories
  // =========================

 Future<List<dynamic>> fetchTopDecorations() async {
  try {
    final response =
        await _client.get('categories/decoration');

    if (response is Map<String, dynamic>) {
      final services =
          response['data']?['services'];

      if (services is List) {
        await CacheService.save(
          CacheKeys.decorations,
          services.take(20).toList(),
        );

        return List<dynamic>.from(services);
      }
    }

    return [];
  } catch (e) {
    return CacheService.getList(
      CacheKeys.decorations,
    );
  }
}

 Future<List<dynamic>> fetchPopularVenues() async {
  try {
    final response =
        await _client.get('categories/venue');

    final services =
        response['data']?['services'];

    if (services is List) {

      await CacheService.save(
        CacheKeys.venues,
        services.take(20).toList(),
      );

      return List<dynamic>.from(services);
    }

    return [];
  } catch (e) {
    return CacheService.getList(
      CacheKeys.venues,
    );
  }
}
  Future<dynamic> servicesDetails(String slug) async {
    return await _client.get('categories/$slug');
  }
  Future<dynamic> serviceDetails(String slug) async {
    return await _client.get('service-details/$slug');
  }

  Future<List<dynamic>> fetchCountries() async {
  try {
    final response =
        await _client.get('get_all_country');

    final data = response['data'] ?? [];

    await CacheService.save(
      CacheKeys.countries,
      data);

    return data;
  } catch (e) {
    return CacheService.getList(
      CacheKeys.countries,
    );
  }
}

Future<List<dynamic>> fetchAllRituals() async {
  try {
    final response = await _client.get('get_all_ritual');
    final data = List<dynamic>.from(response['data'] ?? []);

    await CacheService.save(CacheKeys.auspiciousRituals, data);
    return data;
  } catch (e) {
    return CacheService.getList(CacheKeys.auspiciousRituals);
  }
}

Future<List<dynamic>> fetchAuspiciousYears() async {
  try {
    final response = await _client.get('get_all_year');
    final data = List<dynamic>.from(response['data'] ?? []);

    await CacheService.save(CacheKeys.auspiciousYears, data);
    return data;
  } catch (e) {
    return CacheService.getList(CacheKeys.auspiciousYears);
  }
}

Future<List<dynamic>> fetchAuspiciousMonths() async {
  try {
    final response = await _client.get('get_all_month');
    final data = List<dynamic>.from(response['data'] ?? []);

    await CacheService.save(CacheKeys.auspiciousMonths, data);
    return data;
  } catch (e) {
    return CacheService.getList(CacheKeys.auspiciousMonths);
  }
}

Future<List<dynamic>> fetchRitualAuspiciousDates({
  required Object ritualId,
  required int countryId,
  required String year,
  required String month,
}) async {
  final requestData = {
    'ritual_id': ritualId,
    'country_id': countryId,
    'year': year,
    'month': month,
  };

  debugPrint(
    '========== AUSPICIOUS DATE REQUEST ==========',
  );
  debugPrint(
    'API: get_ritual_auspicious_dates',
  );
  debugPrint(
    'Data sent: $requestData',
  );

  try {
    final response = await _client.post(
      'get_ritual_auspicious_dates',
      requestData,
    );

    debugPrint(
      '========== AUSPICIOUS DATE RESPONSE ==========',
    );
    debugPrint(
      'Response type: ${response.runtimeType}',
    );
    debugPrint(
      'Full response: $response',
    );
    debugPrint(
      'Status: ${response['status']}',
    );
    debugPrint(
      'Data field: ${response['data']}',
    );
    debugPrint(
      'Dates field: ${response['dates']}',
    );

    if (response['status'] == 200) {
      final rawDates =
          response['data'] ??
          response['dates'] ??
          [];

      debugPrint(
        'Selected dates data: $rawDates',
      );
      debugPrint(
        'Selected dates type: '
        '${rawDates.runtimeType}',
      );

      if (rawDates is! List) {
        debugPrint(
          'ERROR: Dates response is not a List',
        );

        throw FormatException(
          'Expected dates to be a List, '
          'but received ${rawDates.runtimeType}',
        );
      }

      final dates =
          List<dynamic>.from(rawDates);

      debugPrint(
        'Number of auspicious dates: '
        '${dates.length}',
      );

      for (
        int index = 0;
        index < dates.length;
        index++
      ) {
        debugPrint(
          'Date [$index]: ${dates[index]}',
        );
      }

      return dates;
    }

    debugPrint(
      'API returned an unsuccessful status.',
    );
    debugPrint(
      'Message: ${response['message']}',
    );

    throw Exception(
      response['message'] ??
          'Failed to load auspicious dates',
    );
  } catch (error, stackTrace) {
    debugPrint(
      '========== AUSPICIOUS DATE ERROR ==========',
    );
    debugPrint(
      'Error: $error',
    );
    debugPrintStack(
      stackTrace: stackTrace,
    );

    rethrow;
  }
}

Future<dynamic> saveBasicDetails({
  required int userId,
  required String firstName,
  required String lastName,
  required String country,
}) async {
  return await _client.post(
    'store_basic_details',
    {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'country': country,
    },
  );
}

Future<List<dynamic>> fetchUserBookings() async {
  final response = await _client.get('user/bookings');
  return response['data'] ?? [];
}



}