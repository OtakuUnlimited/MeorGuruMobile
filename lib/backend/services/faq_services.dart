import 'package:flutter/foundation.dart';

import 'api_client.dart';

class FaqService {
  final ApiClient _client = ApiClient();

  List<Map<String, dynamic>> _extractList(
    dynamic response,
  ) {
    dynamic data = response;

    if (response is Map) {
      data =
          response['data'] ??
          response['faqs'] ??
          response['categories'] ??
          response['items'] ??
          [];

      if (data is Map) {
        data =
            data['data'] ??
            data['faqs'] ??
            data['categories'] ??
            data['items'] ??
            [];
      }
    }

    if (data is! List) {
      return [];
    }

    return data
        .whereType<Map>()
        .map(
          (item) =>
              Map<String, dynamic>.from(item),
        )
        .toList();
  }

  // Get all FAQs
  Future<List<Map<String, dynamic>>>
      fetchFaqs() async {
    try {
      final response =
          await _client.get('faqs');

      debugPrint(
        'FAQ RESPONSE: $response',
      );

      return _extractList(response);
    } catch (error, stackTrace) {
      debugPrint(
        'FAQ FETCH ERROR: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      return [];
    }
  }

  // Get all FAQ categories
  Future<List<Map<String, dynamic>>>
      fetchFaqCategories() async {
    try {
      final response = await _client.get(
        'faq-categories',
      );

      debugPrint(
        'FAQ CATEGORY RESPONSE: $response',
      );

      return _extractList(response);
    } catch (error, stackTrace) {
      debugPrint(
        'FAQ CATEGORY FETCH ERROR: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      return [];
    }
  }

  // Optional: get FAQs using category slug
  Future<List<Map<String, dynamic>>>
      fetchFaqCategory(
    String slug,
  ) async {
    try {
      final encodedSlug =
          Uri.encodeComponent(slug);

      final response = await _client.get(
        'faqs/$encodedSlug',
      );

      return _extractList(response);
    } catch (error, stackTrace) {
      debugPrint(
        'FAQ CATEGORY DETAILS ERROR: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      return [];
    }
  }

  // Search FAQs
  Future<List<Map<String, dynamic>>>
      searchFaqs(
    String query,
  ) async {
    final search = query.trim();

    if (search.isEmpty) {
      return fetchFaqs();
    }

    try {
      final encodedSearch =
          Uri.encodeQueryComponent(search);

      final response = await _client.get(
        'faqs/search?search=$encodedSearch',
      );

      return _extractList(response);
    } catch (error, stackTrace) {
      debugPrint(
        'FAQ SEARCH ERROR: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      return [];
    }
  }
}