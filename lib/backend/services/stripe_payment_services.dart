import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'api_client.dart';

class StripePaymentService {
  StripePaymentService._();

  static final StripePaymentService instance =
      StripePaymentService._();

  final ApiClient _client = ApiClient();

  Future<String?> makeDonation({
    required double amount,
  }) async {
    if (amount < 1) {
      throw Exception(
        'The donation must be at least \$1.',
      );
    }

    try {
      final response = await _client.post(
        'donation/checkout',
        {
          'amount': amount.toStringAsFixed(2),
        },
      );

      debugPrint(
        'DONATION INTENT RESPONSE: $response',
      );

      if (response is! Map) {
        throw Exception(
          'Invalid response from payment server.',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Could not start the donation.',
        );
      }

      final publishableKey =
    response['publishable_key']?.toString();

final clientSecret =
    response['client_secret']?.toString();

if (publishableKey == null ||
    publishableKey.isEmpty) {
  throw Exception(
    'Stripe publishable key is missing.',
  );
}

if (clientSecret == null ||
    clientSecret.isEmpty) {
  throw Exception(
    'Payment client secret is missing.',
  );
}

Stripe.publishableKey = publishableKey;
Stripe.urlScheme = 'meroguru';

await Stripe.instance.applySettings();

await Stripe.instance.initPaymentSheet(
  paymentSheetParameters:
      SetupPaymentSheetParameters(
    paymentIntentClientSecret:
        clientSecret,
    merchantDisplayName: 'Mero Guru',
    style: ThemeMode.system,
  ),
);

await Stripe.instance.presentPaymentSheet();

      return response['payment_intent_id']
          ?.toString();
    } on StripeException catch (error) {
      if (error.error.code ==
          FailureCode.Canceled) {
        return null;
      }

      throw Exception(
        error.error.localizedMessage ??
            'The Stripe payment failed.',
      );
    }
  }
}