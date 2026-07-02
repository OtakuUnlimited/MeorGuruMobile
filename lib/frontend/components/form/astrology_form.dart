import 'package:flutter/material.dart';
import '../../../backend/services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../backend/services/bookings.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../searchable_country_dropdown.dart';
import '../searchable_state_dropdown.dart';
import '../gotra_dropdown.dart';
import '../models/personal_details.dart';

class AstrologyForm extends StatefulWidget {
  final VoidCallback onPaymentSubmit;
  final Map<String, dynamic> astrologyData;
  const AstrologyForm({
  Key? key,
  required this.onPaymentSubmit,
  required this.astrologyData,
}) : super(key: key); 

  

  @override
  State<AstrologyForm> createState() => _AstrologyFormState();
}

class _AstrologyFormState extends State<AstrologyForm> {


 final ApiClient _client = ApiClient();

bool _isSubmitting = false;
bool _agreedToTerms = false;

String _orderForCount = '1';

String? _selectedGotra;
String? _selectedCountry;
String? _selectedState;

String? selectedHour;
String? selectedMinute;

List<PersonDetails> people = [
  PersonDetails(),
];

String? deliveryCountry;
String? deliveryState;
String? selectedGotra;

// ================= Personal Details =================

final TextEditingController fullNameController =
    TextEditingController();

final TextEditingController dobController =
    TextEditingController();

final TextEditingController birthPlaceController =
    TextEditingController();

final TextEditingController birthNameController =
    TextEditingController();

// ================= Family Details =================

final TextEditingController fatherBirthNameController =
    TextEditingController();

final TextEditingController motherBirthNameController =
    TextEditingController();

final TextEditingController notesController =
    TextEditingController();

// ================= Delivery Details =================

final TextEditingController suburbController =
    TextEditingController();

final TextEditingController postCodeController =
    TextEditingController();

final TextEditingController deliveryAddressController =
    TextEditingController();

// ================= Customer Details =================

final TextEditingController customerNameController =
    TextEditingController();

final TextEditingController customerEmailController =
    TextEditingController();

final TextEditingController customerPhoneController =
    TextEditingController();


    Future<void> submitBooking() async {
  print("========== SUBMIT BOOKING ==========");

  try {
    setState(() {
      _isSubmitting = true;
    });

    print("Astrology ID: ${widget.astrologyData['id']}");
    print("Order For: $_orderForCount");

    print("------ Personal Details ------");
    for (int i = 0; i < people.length; i++) {
      final person = people[i];
      print("Person ${i + 1}");
      print("Full Name: ${person.fullNameController.text}");
      print("Gender: ${person.gender}");
      print("DOB: ${person.dobController.text}");
      print("Birth Hour: ${person.birthHour}");
      print("Birth Minute: ${person.birthMinute}");
      print("Birth Country: ${person.birthCountry}");
      print("Birth Place: ${person.birthPlaceController.text}");
      print("Birth Name: ${person.birthNameController.text}");
    }

    print("------ Family Details ------");
    print("Father Gotra: $selectedGotra");
    print("Father Birth Name: ${fatherBirthNameController.text}");
    print("Mother Birth Name: ${motherBirthNameController.text}");
    print("Notes: ${notesController.text}");

    print("------ Delivery Details ------");
    print("Country: $deliveryCountry");
    print("State: $deliveryState");
    print("Address: ${deliveryAddressController.text}");
    print("Suburb: ${suburbController.text}");
    print("Post Code: ${postCodeController.text}");

    print("------ Customer Details ------");
    print("Customer Name: ${customerNameController.text}");
    print("Customer Email: ${customerEmailController.text}");
    print("Customer Phone: ${customerPhoneController.text}");

    final body = {
      'astrology_id': widget.astrologyData['id'],
      'order_for': _orderForCount,

      // TEMPORARILY send first person only
      'full_name': people.first.fullNameController.text,
      'gender': people.first.gender,
      'dob': people.first.dobController.text,
      'place_of_birth': people.first.birthPlaceController.text,
      'birth_name': people.first.birthNameController.text,

      'customer_name': customerNameController.text,
      'customer_email': customerEmailController.text,
      'customer_phone': customerPhoneController.text,

      'delivery_country': deliveryCountry,
      'delivery_state': deliveryState,
      'delivery_address': deliveryAddressController.text,
      'post_code': postCodeController.text,

      'amount': widget.astrologyData['price'],
    };

    print("------ REQUEST BODY ------");
    print(body);

    print("Calling API...");

    final response = await _client.post(
      'astrology/booking',
      body,
    );

    print("API SUCCESS");
    print(response);

    final stripeUrl = response['stripe_url'];

    print("Stripe URL: $stripeUrl");

    if (stripeUrl != null) {
      print("Launching Stripe...");
      await launchUrl(
        Uri.parse(stripeUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      print("No stripe_url returned.");
    }
  } catch (e, stackTrace) {
    print("========== ERROR ==========");
    print(e);
    print(stackTrace);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  } finally {
    print("========== END ==========");

    setState(() {
      _isSubmitting = false;
    });
  }
}

@override
void dispose() {
  fullNameController.dispose();
  dobController.dispose();
  birthPlaceController.dispose();
  birthNameController.dispose();

  fatherBirthNameController.dispose();
  motherBirthNameController.dispose();
  notesController.dispose();

  suburbController.dispose();
  postCodeController.dispose();
  deliveryAddressController.dispose();

  customerNameController.dispose();
  customerEmailController.dispose();
  customerPhoneController.dispose();

  super.dispose();
}

    

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= ORDER DETAILS =================
          _buildSectionHeader('Order Details:'),
          _buildFieldLabel('Order or Service For:'),
          _buildDropdownField(
            value: _orderForCount,
            items: ['1', '2', '3', '4','5','6','7','8','9','10'],
            onChanged: (val) => setState(() => _orderForCount = val!),
          ),
          const SizedBox(height: 20),

          // ================= PERSONAL DETAILS =================
          _buildSectionHeader("Personal Details"),

          const SizedBox(height:15),

          Column(
            children: List.generate(
              people.length,
              (index) => _buildPersonCard(index),
            ),
          ),

          const SizedBox(height:20),

          // ================= FAMILY DETAILS =================
          _buildSectionHeader('Family Details:'),
          _buildFieldLabel('Father\'s Gotra:'),
          GotraDropdown(
            initialValue: selectedGotra,
            onChanged: (value) {
              setState(() {
                selectedGotra = value;
              });
            },
          ),
          _buildFieldLabel('Father\'s Birth Name:'),
          _buildTextField( controller: fatherBirthNameController,),
          _buildFieldLabel('Mother\'s Birth Name:'),
          _buildTextField( controller: motherBirthNameController,),
          _buildFieldLabel('Additional Notes:', isRequired: false),
          _buildTextField(maxLines: 3, hintText: 'Please include additional information, your wish to add'),
          const SizedBox(height: 20),

          // ================= DELIVERY INFORMATION =================
          _buildSectionHeader('Delivery Information:'),
            _buildFieldLabel('Country:'),
            Column(

            children: [
               SearchableCountryDropdown(
              label: "",
              initialCountry: _selectedCountry,
              onChanged: (country) {
                setState(() {
                  _selectedCountry = country;
                  deliveryCountry = country;
                  

                    if (country != "Australia") {
                        deliveryState = null;
                    }
                });
              },
              
            ),
            if (deliveryCountry == "Australia")
            const SizedBox(height: 16),

                  if (deliveryCountry == "Australia")
                  
                      SearchableStateDropdown(
                          country: "Australia",
                          initialState: deliveryState,
                          onChanged: (state) {

                              setState(() {
                                  deliveryState = state;
                              });

                          },
                      ),

              ],

          ),
          _buildFieldLabel('Suburb:'),
          _buildTextField( controller: suburbController,),
          _buildFieldLabel('Post Code:'),
          _buildTextField( controller: postCodeController,),
          _buildFieldLabel('Delivery Address:'),
          _buildTextField( controller: deliveryAddressController,),
          const SizedBox(height: 20),

          // ================= YOUR DETAILS =================
          _buildSectionHeader('Your Details:'),
          _buildFieldLabel('Full Name:'),
          _buildTextField(
            controller: customerNameController,
            hintText: 'John Doe',
          ),
          _buildFieldLabel('Email Address:'),
          _buildTextField(
            controller: customerEmailController,
            hintText: 'JohnDoe@gmail.com',
          ),
          _buildFieldLabel('Phone Number:'),

          IntlPhoneField(
            initialCountryCode: 'AU',
            decoration: InputDecoration(
              hintText: 'Phone Number',
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (phone) {
              customerPhoneController.text = phone.number;

              // Save country code if needed
              print(phone.countryCode);
            },
          ),
          const SizedBox(height: 16),

          // Terms & Agreement Row Block
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agreedToTerms,
                  activeColor: const Color(0xFFFA6400),
                  onChanged: (val) => setState(() => _agreedToTerms = val!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.3),
                    children: [
                      TextSpan(text: 'I agree to the MeroGuru '),
                      TextSpan(text: 'Terms and Conditions ', style: TextStyle(color: Color(0xFFFA6400), fontWeight: FontWeight.w500)),
                      TextSpan(text: 'and '),
                      TextSpan(text: 'Privacy Policy', style: TextStyle(color: Color(0xFFFA6400), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Pricing Summary Section Row layout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Payment Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text('\$100', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),

          // Final Action Core CTA Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFA6400), // Exact orange brand color match
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: !_agreedToTerms || _isSubmitting
              ? null
             : submitBooking,  
              child: _isSubmitting
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Text(
                    'Debit or Credit Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Design Token Section Divider Builder ---
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        const Divider(color: Colors.black87, thickness: 1.2, height: 12),
        const SizedBox(height: 8),
      ],
    );
  }

  // --- Input Matrix Field Labels with Red Astreisks ---
  Widget _buildFieldLabel(String label, {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
          children: [
            TextSpan(text: label),
            if (isRequired) const TextSpan(text: '*', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  // --- Text Field Core Config Builder ---
  Widget _buildTextField({
  TextEditingController? controller,
  String? hintText,
  Widget? suffixIcon,
  int maxLines = 1,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 4),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 13,
        ),
        fillColor: const Color(0xFFF8F9FA),
        filled: true,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

  // --- Dropdown Selector Frame Config Builder ---
  Widget _buildDropdownField({
    required String? value,
    String? hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint != null ? Text(hint, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)) : null,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPersonCard(int index) {

  final person = people[index];

  return Card(
    elevation: 0,
    color: Colors.transparent,
    margin: const EdgeInsets.only(bottom: 25),

    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [

            Text(
              "Individual ${index + 1}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),

            Row(

              children: [

                if(index==people.length-1)

                  ElevatedButton(

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                    ),

                    onPressed: () {

                      setState(() {

                        people.add(PersonDetails());

                      });

                    },

                    child: const Text(
                      "+ Add",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),

                if(people.length>1)

                  IconButton(

                    onPressed: () {

                      setState(() {

                        people[index].dispose();

                        people.removeAt(index);

                      });

                    },

                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),

                  )

              ],

            )

          ],

        ),

        const SizedBox(height:15),

        _buildFieldLabel("Full Name:"),

        _buildTextField(
          controller: person.fullNameController,
          hintText: "John Doe",
        ),

        _buildFieldLabel("Gender:"),

        _buildDropdownField(

          value: person.gender,

          hint: "Select Gender",

          items: const [
            "Male",
            "Female",
          ],

          onChanged: (value){

            setState(() {

              person.gender=value;

            });

          },

        ),

        Row(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Expanded(

              flex:5,

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _buildFieldLabel("Date of Birth:"),

                  TextField(

                    controller: person.dobController,

                    readOnly: true,

                    decoration: InputDecoration(

                      suffixIcon: const Icon(Icons.calendar_today),

                      filled: true,

                      fillColor: const Color(0xFFF8F9FA),

                      border: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(8),

                        borderSide: BorderSide.none,

                      ),

                    ),

                    onTap: () async {

                      final date=await showDatePicker(

                        context: context,

                        initialDate: DateTime.now(),

                        firstDate: DateTime(1900),

                        lastDate: DateTime.now(),

                      );

                      if(date!=null){

                        person.dobController.text=

                            "${date.day.toString().padLeft(2,'0')}-"

                            "${date.month.toString().padLeft(2,'0')}-"

                            "${date.year}";

                      }

                    },

                  )

                ],

              ),

            ),

            const SizedBox(width:12),

            Expanded(

              flex:6,

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  _buildFieldLabel("Time of Birth:"),

                  Row(

                    children: [

                      Expanded(

                        child:_buildDropdownField(

                          value: person.birthHour,

                          hint: "00",

                          items: List.generate(

                            24,

                            (i)=>i.toString().padLeft(2,"0"),

                          ),

                          onChanged: (value){

                            setState(() {

                              person.birthHour=value;

                            });

                          },

                        ),

                      ),

                      const Padding(

                        padding: EdgeInsets.symmetric(horizontal:4),

                        child: Text("Hr"),

                      ),

                      Expanded(

                        child:_buildDropdownField(

                          value: person.birthMinute,

                          hint: "00",

                          items: List.generate(

                            60,

                            (i)=>i.toString().padLeft(2,"0"),

                          ),

                          onChanged: (value){

                            setState(() {

                              person.birthMinute=value;

                            });

                          },

                        ),

                      ),

                      const Padding(

                        padding: EdgeInsets.symmetric(horizontal:4),

                        child: Text("Min"),

                      )

                    ],

                  )

                ],

              ),

            )

          ],

        ),

        _buildFieldLabel("Country of Birth:"),

        SearchableCountryDropdown(

          label: "",

          initialCountry: person.birthCountry,

          onChanged: (country){

            setState(() {

              person.birthCountry=country;

            });

          },

        ),

        _buildFieldLabel("Place/City of Birth:"),

        _buildTextField(

          controller: person.birthPlaceController,

        ),

        _buildFieldLabel("Birth Name:"),

        _buildTextField(

          controller: person.birthNameController,

        ),

      ],

    ),

  );

}
}