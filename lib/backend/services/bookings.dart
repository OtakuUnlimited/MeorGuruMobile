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
    'mobile/astrology/booking',
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

Future<dynamic> createPujaBooking({
  required int pujaId,
  required String bookingFor,
  required String date,
  required String time,
  required String timezone,
  required String firstName,
  required String lastName,
  required String email,
  required String country,
  required String amount,
  String? caste,
  String? gotra,
  String? address,
  String? city,
  String? state,
  String? suburb,
  String? postalCode,
  String? note,
}) async {
  return await _client.post(
    'mobile/puja/booking',
    {
      'puja_id': pujaId,
      'puja_booking_for': bookingFor,
      'date': date,
      'time': time,
      'timezone': timezone,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'country': country,
      'amount': amount,
      'caste': caste,
      'gotra': gotra,
      'address': address,
      'city': city,
      'state': state,
      'suburb': suburb,
      'postal_code': postalCode,
      'note': note,
    },
  );
}

Future<dynamic> createEventBooking({
  required int eventId,
  required String eventName,
  required String bookingFor,
  required String eventDate,
  required String startTime,
  required String endTime,
  required String customerName,
  required String customerEmail,
  required String customerPhone,
  required String country,
  required String amount,
}) async {
  return await _client.post(
    'mobile/event/booking',
    {
      'event_id': eventId,
      'event_name': eventName,
      'puja_booking_for': bookingFor,
      'event_date': eventDate,
      'event_start_time': startTime,
      'event_end_time': endTime,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'event_country': country,
      'amount': amount,
    },
  );
}