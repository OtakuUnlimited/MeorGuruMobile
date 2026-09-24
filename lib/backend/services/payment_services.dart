import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String baseUrl =
      'https://teal-moose-685827.hostingersite.com/public/api';

  static Future<bool> makePayment({
    required int amount,
    String currency = 'aud',
  }) async {
    try {
      // 1. Ask Laravel to create the PaymentIntent
      final response = await http.post(
        Uri.parse('$baseUrl/payment/create-intent'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': currency,
        }),
      );

      if (response.statusCode != 200) {
        print('PaymentIntent error: ${response.body}');
        return false;
      }

      final data = jsonDecode(response.body);

      if (data['status'] != true) {
        print('PaymentIntent failed: ${data['message']}');
        return false;
      }

      final clientSecret = data['client_secret'];

      if (clientSecret == null ||
          clientSecret.toString().isEmpty) {
        print('No client secret returned');
        return false;
      }

      // 2. Initialize Stripe Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Mero Guru',
        ),
      );

      // 3. Show Stripe Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } on StripeException catch (e) {
      print(
        'Stripe error: ${e.error.localizedMessage}',
      );

      return false;
    } catch (e) {
      print('Payment error: $e');
      return false;
    }
  }
}