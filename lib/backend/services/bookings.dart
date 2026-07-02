import 'api_client.dart';

final ApiClient _client = ApiClient();

Future<dynamic> createAstrologyBooking({
  required int astrologyId,
  required String orderFor,
  required String fullName,
  required String dob,
  required String placeOfBirth,
  required String gender,
  required String customerName,
  required String customerEmail,
  required String customerPhone,
  required String deliveryCountry,
  required String deliveryAddress,
  required String postCode,
  required String amount,
}) async {
  return await _client.post(
    'astrology/booking',
    {
      'astrology_id': astrologyId,
      'order_for': orderFor,
      'full_name': fullName,
      'dob': dob,
      'place_of_birth': placeOfBirth,
      'gender': gender,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'delivery_country': deliveryCountry,
      'delivery_address': deliveryAddress,
      'post_code': postCode,
      'amount': amount,
    },
  );
}