import 'package:flutter/foundation.dart';

import 'api_client.dart';

class AskMeroGuruService {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> fetchAskMeroGuru() async {
    final response = await _client.get(
      'ask-mero-guru',
    );

    debugPrint(
      'ASK MERO GURU RESPONSE: $response',
    );

    if (response is! Map) {
      throw Exception(
        'Invalid Ask Mero Guru response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  Future<List<Map<String, dynamic>>> fetchTopicInputs(
    String topicSlug,
  ) async {
    final endpoint = Uri(
      path: 'qna-topic-inputs',
      queryParameters: {
        'topic': topicSlug,
      },
    ).toString();

    final response = await _client.get(endpoint);

    debugPrint(
      'QNA TOPIC INPUTS RESPONSE: $response',
    );

    dynamic rawInputs = response;

    if (response is Map) {
      rawInputs =
          response['data'] ??
          response['qna_topic_inputs'] ??
          [];
    }

    if (rawInputs is! List) {
      return [];
    }

    return rawInputs
        .map<Map<String, dynamic>>(
          (input) => Map<String, dynamic>.from(
            input as Map,
          ),
        )
        .toList();
  }

  Future<String> fetchTopicResponse(
    String condition,
  ) async {
    final endpoint = Uri(
      path: 'qna-topic-response',
      queryParameters: {
        'condition': condition,
      },
    ).toString();

    final response = await _client.get(endpoint);

    debugPrint(
      'QNA FINAL RESPONSE: $response',
    );

    if (response is! Map) {
      throw Exception(
        'Invalid Guru response.',
      );
    }

    return response['response']?.toString() ??
        'No response was found.';
  }
}