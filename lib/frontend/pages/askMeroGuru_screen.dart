import 'package:flutter/material.dart';

import '../../backend/services/ask_mero_guru_services.dart';
import 'package:flutter/services.dart';

class AskMeroGuruScreen extends StatefulWidget {
  const AskMeroGuruScreen({
    super.key,
  });

  @override
  State<AskMeroGuruScreen> createState() =>
      _AskMeroGuruScreenState();
}

class _AskMeroGuruScreenState
    extends State<AskMeroGuruScreen> {
  final AskMeroGuruService _service =
      AskMeroGuruService();

  final TextEditingController _searchController =
      TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _allTopics = [];
  List<Map<String, dynamic>> _filteredTopics = [];
  List<Map<String, dynamic>> _topicInputs = [];

  int? _selectedCategoryId;
  int? _selectedTopicId;

  Map<String, dynamic>? _selectedTopic;

  final Map<int, String> _selectedInputValues = {};
  final Map<int, TextEditingController>
      _inputControllers = {};

  bool _loading = true;
  bool _loadingInputs = false;
  bool _loadingResponse = false;

  String? _error;
  String? _guruResponse;

  @override
  void initState() {
    super.initState();
    _loadAskMeroGuru();
  }

  String _optionImage(dynamic option) {
  if (option is Map) {
    return (
      option['image_url'] ??
      option['image'] ??
      option['icon'] ??
      option['thumbnail'] ??
      ''
    ).toString();
  }

  return '';
}

String _optionDescription(dynamic option) {
  if (option is Map) {
    return (
      option['description'] ??
      option['subtitle'] ??
      ''
    ).toString();
  }

  return '';
}

Future<void> _selectDate(
  Map<String, dynamic> input,
) async {
  final inputId = int.tryParse(
    input['id']?.toString() ?? '',
  );

  if (inputId == null) return;

  final controller =
      _inputControllers[inputId];

  DateTime initialDate = DateTime.now();

  if (controller != null &&
      controller.text.isNotEmpty) {
    initialDate =
        DateTime.tryParse(controller.text) ??
            DateTime.now();
  }

  final selectedDate =
      await showDatePicker(
    context: context,
    initialDate: initialDate,

    // Allows previous dates.
    firstDate: DateTime(1900),

    // Allows future dates.
    lastDate: DateTime(2100),
    helpText: _inputLabel(input),
    confirmText: 'SELECT',
    cancelText: 'CANCEL',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(
            primary: Color(0xFFFF6600),
            onPrimary: Colors.white,
            onSurface: Colors.black87,
          ),
        ),
        child: child!,
      );
    },
  );

  if (selectedDate == null) return;

  final formattedDate =
      '${selectedDate.year.toString().padLeft(4, '0')}-'
      '${selectedDate.month.toString().padLeft(2, '0')}-'
      '${selectedDate.day.toString().padLeft(2, '0')}';

  controller?.text = formattedDate;

  setState(() {
    _selectedInputValues[inputId] =
        formattedDate;
    _guruResponse = null;
  });
}

  Future<void> _loadAskMeroGuru() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response =
          await _service.fetchAskMeroGuru();

      final rawCategories =
          response['qna_categories'];

      final rawTopics = response['qna_topics'];

      final categories = rawCategories is List
          ? rawCategories
              .map<Map<String, dynamic>>(
                (item) =>
                    Map<String, dynamic>.from(
                  item as Map,
                ),
              )
              .toList()
          : <Map<String, dynamic>>[];

      final topics = rawTopics is List
          ? rawTopics
              .map<Map<String, dynamic>>(
                (item) =>
                    Map<String, dynamic>.from(
                  item as Map,
                ),
              )
              .toList()
          : <Map<String, dynamic>>[];

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _allTopics = topics;
        _filteredTopics = topics;
        _loading = false;
      });
    } catch (error, stackTrace) {
      debugPrint(
        'ASK MERO GURU ERROR: $error',
      );
      debugPrintStack(
        stackTrace: stackTrace,
      );

      if (!mounted) return;

      setState(() {
        _error = error
            .toString()
            .replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _selectAllPopular() {
    setState(() {
      _selectedCategoryId = null;

      _filteredTopics = _allTopics.where(
        (topic) {
          final popular =
              topic['is_popular'];

          return popular == true ||
              popular == 1 ||
              popular?.toString() == '1';
        },
      ).toList();

      if (_filteredTopics.isEmpty) {
        _filteredTopics =
            List<Map<String, dynamic>>.from(
          _allTopics,
        );
      }

      _clearSelectedTopic();
    });
  }

  void _selectCategory(
    Map<String, dynamic> category,
  ) {
    final categoryId = int.tryParse(
      category['id']?.toString() ?? '',
    );

    if (categoryId == null) return;

    setState(() {
      _selectedCategoryId = categoryId;

      _filteredTopics = _allTopics.where(
        (topic) {
          final topicCategoryId = int.tryParse(
            topic['category_id']
                    ?.toString() ??
                '',
          );

          return topicCategoryId == categoryId;
        },
      ).toList();

      _clearSelectedTopic();
    });
  }

  void _clearSelectedTopic() {
    _selectedTopicId = null;
    _selectedTopic = null;
    _topicInputs = [];
    _selectedInputValues.clear();
    _guruResponse = null;

    for (final controller
        in _inputControllers.values) {
      controller.dispose();
    }

    _inputControllers.clear();
  }

  Future<void> _selectTopic(
    Map<String, dynamic> topic,
  ) async {
    final topicId = int.tryParse(
      topic['id']?.toString() ?? '',
    );

    final topicSlug =
        topic['slug']?.toString() ?? '';

    if (topicId == null ||
        topicSlug.isEmpty) {
      return;
    }

    if (_selectedTopicId == topicId) {
      setState(() {
        _clearSelectedTopic();
      });
      return;
    }

    setState(() {
      _selectedTopicId = topicId;
      _selectedTopic = topic;
      _topicInputs = [];
      _selectedInputValues.clear();
      _guruResponse = null;
      _loadingInputs = true;
    });

    try {
      final inputs =
          await _service.fetchTopicInputs(
        topicSlug,
      );

      if (!mounted ||
          _selectedTopicId != topicId) {
        return;
      }

      for (final controller
          in _inputControllers.values) {
        controller.dispose();
      }

      _inputControllers.clear();

      for (final input in inputs) {
        final inputId = int.tryParse(
          input['id']?.toString() ?? '',
        );

        if (inputId != null) {
          _inputControllers[inputId] =
              TextEditingController();
        }
      }

      setState(() {
        _topicInputs = inputs;
        _loadingInputs = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadingInputs = false;
      });

      _showError(
        error
            .toString()
            .replaceFirst('Exception: ', ''),
      );
    }
  }

  void _searchTopics() {
    final query = _searchController.text
        .trim()
        .toLowerCase();

    if (query.isEmpty) {
      if (_selectedCategoryId == null) {
        _selectAllPopular();
      } else {
        final category = _categories.firstWhere(
          (item) =>
              item['id']?.toString() ==
              _selectedCategoryId.toString(),
        );

        _selectCategory(category);
      }

      return;
    }

    setState(() {
      _filteredTopics = _allTopics.where(
        (topic) {
          final title = topic['title']
                  ?.toString()
                  .toLowerCase() ??
              '';

          final description =
              topic['description']
                      ?.toString()
                      .toLowerCase() ??
                  '';

          final categoryName =
              (topic['category'] is Map)
                  ? (topic['category']['name']
                              ?.toString()
                              .toLowerCase() ??
                      '')
                  : '';

          return title.contains(query) ||
              description.contains(query) ||
              categoryName.contains(query);
        },
      ).toList();

      _selectedCategoryId = null;
      _clearSelectedTopic();
    });
  }

  List<dynamic> _getOptions(
    Map<String, dynamic> input,
  ) {
    final options = input['options'];

    if (options is List) {
      return options;
    }

    return [];
  }

  String _optionLabel(dynamic option) {
    if (option is Map) {
      return (
        option['label'] ??
        option['name'] ??
        option['title'] ??
        option['value'] ??
        option['condition'] ??
        ''
      ).toString();
    }

    return option.toString();
  }

  String _optionValue(dynamic option) {
    if (option is Map) {
      return (
        option['condition'] ??
        option['value'] ??
        option['id'] ??
        option['name'] ??
        option['label'] ??
        ''
      ).toString();
    }

    return option.toString();
  }

  String _inputLabel(
    Map<String, dynamic> input,
  ) {
    return (
      input['label'] ??
      input['title'] ??
      input['name'] ??
      'Select an option'
    ).toString();
  }

  String _inputType(
    Map<String, dynamic> input,
  ) {
    return (
      input['input_type'] ??
      input['type'] ??
      'select'
    ).toString().toLowerCase();
  }

  Future<void> _submitTopic() async {
  if (_topicInputs.isEmpty) {
    _showError(
      'No inputs are available for this topic.',
    );
    return;
  }

  String? condition;

  for (final input in _topicInputs) {
    final inputId = int.tryParse(
      input['id']?.toString() ?? '',
    );

    if (inputId == null) continue;

    final type = _inputType(input);

    String value;

    if (type == 'text' ||
        type == 'number') {
      value = _inputControllers[inputId]
              ?.text
              .trim() ??
          '';
    } else {
      value =
          _selectedInputValues[inputId] ?? '';
    }

    if (value.isEmpty) {
      _showError(
        'Please complete ${_inputLabel(input)}.',
      );
      return;
    }

    condition = value;
  }

  if (condition == null ||
      condition.isEmpty) {
    _showError(
      'Please select or enter a value.',
    );
    return;
  }

  setState(() {
    _loadingResponse = true;
    _guruResponse = null;
  });

  try {
    final response =
        await _service.fetchTopicResponse(
      condition,
    );

    if (!mounted) return;

    setState(() {
      _guruResponse = response;
      _loadingResponse = false;
    });
  } catch (error, stackTrace) {
    debugPrint(
      'QNA RESPONSE ERROR: $error',
    );
    debugPrintStack(
      stackTrace: stackTrace,
    );

    if (!mounted) return;

    setState(() {
      _loadingResponse = false;
    });

    _showError(
      error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('HttpException: ', ''),
    );
  }
}

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
  }

  Widget _buildTopicInput(
  Map<String, dynamic> input,
) {
  final inputId = int.tryParse(
    input['id']?.toString() ?? '',
  );

  if (inputId == null) {
    return const SizedBox.shrink();
  }

  final inputType = _inputType(input);
  final label = _inputLabel(input);
  final options = _getOptions(input);

  switch (inputType) {
    case 'number':
      return _buildTextInput(
        input: input,
        inputId: inputId,
        label: label,
        keyboardType:
            const TextInputType.numberWithOptions(
          decimal: true,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(r'^\d*\.?\d{0,2}'),
          ),
        ],
      );

    case 'date':
      return _buildDateInput(
        input: input,
        inputId: inputId,
        label: label,
      );

    case 'select':
    case 'dropdown':
      return _buildSelectInput(
        input: input,
        inputId: inputId,
        label: label,
        options: options,
      );

    case 'choice':
      return _buildChoiceInput(
        input: input,
        inputId: inputId,
        label: label,
        options: options,
      );

    case 'text':
    default:
      return _buildTextInput(
        input: input,
        inputId: inputId,
        label: label,
        keyboardType: TextInputType.text,
      );
  }
}
Widget _buildTextInput({
  required Map<String, dynamic> input,
  required int inputId,
  required String label,
  required TextInputType keyboardType,
  List<TextInputFormatter>? inputFormatters,
}) {
  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),

      const SizedBox(height: 8),

      TextField(
        controller:
            _inputControllers[inputId],
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: (value) {
          _selectedInputValues[inputId] =
              value.trim();

          if (_guruResponse != null) {
            setState(() {
              _guruResponse = null;
            });
          }
        },
        decoration: InputDecoration(
          hintText:
              input['placeholder']?.toString() ??
                  'Enter $label',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
          filled: true,
          fillColor:
              const Color(0xFFFAFAFA),
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFFF6600),
              width: 1.5,
            ),
          ),
        ),
      ),

      const SizedBox(height: 20),
    ],
  );
}
Widget _buildDateInput({
  required Map<String, dynamic> input,
  required int inputId,
  required String label,
}) {
  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),

      const SizedBox(height: 8),

      TextField(
        controller:
            _inputControllers[inputId],
        readOnly: true,
        onTap: () => _selectDate(input),
        decoration: InputDecoration(
          hintText:
              input['placeholder']?.toString() ??
                  'Select date',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
          filled: true,
          fillColor:
              const Color(0xFFFAFAFA),
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
            color: Color(0xFFFF6600),
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
            ),
          ),
          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(8),
            borderSide: const BorderSide(
              color: Color(0xFFFF6600),
              width: 1.5,
            ),
          ),
        ),
      ),

      const SizedBox(height: 20),
    ],
  );
}
Widget _buildSelectInput({
  required Map<String, dynamic> input,
  required int inputId,
  required String label,
  required List<dynamic> options,
}) {
  final selectedValue =
      _selectedInputValues[inputId];

  final availableValues = options
      .map(_optionValue)
      .where((value) => value.isNotEmpty)
      .toSet();

  final safeSelectedValue =
      availableValues.contains(selectedValue)
          ? selectedValue
          : null;

  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),

      const SizedBox(height: 8),

      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius:
              BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: safeSelectedValue,
            isExpanded: true,
            hint: Text(
              input['placeholder']?.toString() ??
                  'Select $label',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            items: options.map(
              (option) {
                final value =
                    _optionValue(option);

                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    _optionLabel(option),
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                );
              },
            ).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedInputValues[inputId] =
                    value;
                _guruResponse = null;
              });
            },
          ),
        ),
      ),

      const SizedBox(height: 20),
    ],
  );
}
Widget _buildChoiceInput({
  required Map<String, dynamic> input,
  required int inputId,
  required String label,
  required List<dynamic> options,
}) {
  final selectedValue =
      _selectedInputValues[inputId];

  return Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),

      const SizedBox(height: 12),

      if (options.isEmpty)
        const Text(
          'No choices are available.',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        )
      else
        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final option = options[index];
            final value =
                _optionValue(option);
            final optionLabel =
                _optionLabel(option);
            final imageUrl =
                _optionImage(option);
            final description =
                _optionDescription(option);

            final selected =
                selectedValue == value;

            return InkWell(
              borderRadius:
                  BorderRadius.circular(12),
              onTap: _loadingResponse
                  ? null
                  : () async {
                      setState(() {
                        _selectedInputValues[
                            inputId] = value;
                        _guruResponse = null;
                      });

                      // Selecting an image immediately
                      // obtains and displays the result.
                      await _submitTopic();
                    },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? const Color(
                            0xFFFF6600,
                          )
                        : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.03),
                      blurRadius: 5,
                      offset:
                          const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius
                                .vertical(
                          top: Radius.circular(11),
                        ),
                        child: imageUrl.isEmpty
                            ? Container(
                                width:
                                    double.infinity,
                                color: Colors
                                    .grey.shade100,
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 45,
                                  color: Colors.grey,
                                ),
                              )
                            : Image.network(
                                imageUrl,
                                width:
                                    double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (
                                  context,
                                  error,
                                  stackTrace,
                                ) {
                                  return Container(
                                    color: Colors
                                        .grey.shade100,
                                    child:
                                        const Icon(
                                      Icons
                                          .broken_image_outlined,
                                      size: 45,
                                      color:
                                          Colors.grey,
                                    ),
                                  );
                                },
                              ),
                      ),
                    ),

                    Padding(
                      padding:
                          const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  optionLabel,
                                  textAlign:
                                      TextAlign.center,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        selected
                                            ? FontWeight
                                                .bold
                                            : FontWeight
                                                .w500,
                                    color:
                                        Colors.black87,
                                  ),
                                ),
                              ),
                              if (selected)
                                const Icon(
                                  Icons
                                      .check_circle,
                                  size: 19,
                                  color: Color(
                                    0xFFFF6600,
                                  ),
                                ),
                            ],
                          ),

                          if (description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              description,
                              textAlign:
                                  TextAlign.center,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors
                                    .grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

      if (_loadingResponse) ...[
        const SizedBox(height: 16),
        const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF6600),
          ),
        ),
      ],

      const SizedBox(height: 20),
    ],
  );
}

  @override
  void dispose() {
    _searchController.dispose();

    for (final controller
        in _inputControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 18,
          ),
          onPressed: () =>
              Navigator.maybePop(context),
        ),
        title: const Text(
          'askMeroGuru',
          style: TextStyle(
            color: Color(0xFFFF6600),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.black87,
            ),
            onPressed: _searchTopics,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed:
                            _loadAskMeroGuru,
                        child:
                            const Text('Try again'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                          border: Border.all(
                            color:
                                Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller:
                                  _searchController,
                              textInputAction:
                                  TextInputAction.search,
                              onSubmitted: (_) =>
                                  _searchTopics(),
                              decoration:
                                  InputDecoration(
                                hintText:
                                    'Type your question or keyword here',
                                hintStyle:
                                    const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor:
                                    const Color(
                                  0xFFFAFAFA,
                                ),
                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(8),
                                  borderSide:
                                      BorderSide(
                                    color: Colors
                                        .grey.shade300,
                                  ),
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(8),
                                  borderSide:
                                      BorderSide(
                                    color: Colors
                                        .grey.shade300,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(
                                    0xFFFF6600,
                                  ),
                                  elevation: 0,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(8),
                                  ),
                                ),
                                onPressed:
                                    _searchTopics,
                                child: const Text(
                                  'Ask Meroguru',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Popular Topics',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight:
                              FontWeight.bold,
                          color: Color(0xFFFF6600),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Choose a topic to begin your spiritual journey',
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding:
                            const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                          border: Border.all(
                            color:
                                Colors.grey.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Categories',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Divider(
                              color:
                                  Color(0xFFFF6600),
                              thickness: 2,
                              height: 12,
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 210,
                              child: ListView(
                                children: [
                                  InkWell(
                                    onTap:
                                        _selectAllPopular,
                                    child: Container(
                                      margin:
                                          const EdgeInsets
                                              .only(
                                        bottom: 6,
                                      ),
                                      padding:
                                          const EdgeInsets
                                              .symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color:
                                            _selectedCategoryId ==
                                                    null
                                                ? const Color(
                                                    0xFFFF6600,
                                                  )
                                                : Colors
                                                    .transparent,
                                        borderRadius:
                                            BorderRadius
                                                .circular(8),
                                      ),
                                      child: Text(
                                        'All Popular',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight:
                                              _selectedCategoryId ==
                                                      null
                                                  ? FontWeight
                                                      .bold
                                                  : FontWeight
                                                      .w500,
                                          color:
                                              _selectedCategoryId ==
                                                      null
                                                  ? Colors.white
                                                  : Colors
                                                      .black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                  ..._categories.map(
                                    (category) {
                                      final id =
                                          int.tryParse(
                                        category['id']
                                                ?.toString() ??
                                            '',
                                      );

                                      final selected =
                                          _selectedCategoryId ==
                                              id;

                                      return InkWell(
                                        onTap: () =>
                                            _selectCategory(
                                          category,
                                        ),
                                        child: Container(
                                          margin:
                                              const EdgeInsets
                                                  .only(
                                            bottom: 6,
                                          ),
                                          padding:
                                              const EdgeInsets
                                                  .symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration:
                                              BoxDecoration(
                                            color: selected
                                                ? const Color(
                                                    0xFFFF6600,
                                                  )
                                                : Colors
                                                    .transparent,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(8),
                                          ),
                                          child: Text(
                                            category['name']
                                                    ?.toString() ??
                                                '',
                                            style:
                                                TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: selected
                                                  ? FontWeight
                                                      .bold
                                                  : FontWeight
                                                      .w500,
                                              color: selected
                                                  ? Colors.white
                                                  : Colors
                                                      .black87,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (_filteredTopics.isEmpty)
                        const Padding(
                          padding:
                              EdgeInsets.symmetric(
                            vertical: 24,
                          ),
                          child: Center(
                            child: Text(
                              'No topics are available.',
                            ),
                          ),
                        ),

                      ..._filteredTopics.map(
                        (topic) {
                          final topicId =
                              int.tryParse(
                            topic['id']
                                    ?.toString() ??
                                '',
                          );

                          final selected =
                              _selectedTopicId ==
                                  topicId;

                          return Column(
                            children: [
                              InkWell(
                                onTap: () =>
                                    _selectTopic(topic),
                                child: Container(
                                  margin:
                                      const EdgeInsets
                                          .only(
                                    bottom: 12,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius
                                            .circular(12),
                                    border: Border.all(
                                      color: selected
                                          ? const Color(
                                              0xFFFF6600,
                                            )
                                          : Colors.grey
                                              .shade200,
                                      width: selected
                                          ? 1.5
                                          : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          topic['title']
                                                  ?.toString() ??
                                              '',
                                          style:
                                              TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                                selected
                                                    ? FontWeight
                                                        .bold
                                                    : FontWeight
                                                        .w500,
                                            color: Colors
                                                .black87,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        selected
                                            ? Icons
                                                .keyboard_arrow_up
                                            : Icons
                                                .keyboard_arrow_down,
                                        color: Colors
                                            .grey.shade600,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (selected)
                                Container(
                                  width:
                                      double.infinity,
                                  margin:
                                      const EdgeInsets
                                          .only(
                                    bottom: 12,
                                  ),
                                  padding:
                                      const EdgeInsets
                                          .all(20),
                                  decoration:
                                      BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius
                                            .circular(16),
                                    border: Border.all(
                                      color: Colors
                                          .grey.shade200,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors
                                            .black
                                            .withOpacity(
                                          0.02,
                                        ),
                                        blurRadius: 8,
                                        offset:
                                            const Offset(
                                          0,
                                          4,
                                        ),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        topic['title']
                                                ?.toString() ??
                                            '',
                                        style:
                                            const TextStyle(
                                          fontSize: 18,
                                          fontWeight:
                                              FontWeight.bold,
                                          color: Color(
                                            0xFFFF6600,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 6,
                                      ),

                                      Text(
                                        topic['description']
                                                ?.toString() ??
                                            'Fill in your details and receive spiritual guidance',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors
                                              .grey.shade600,
                                        ),
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),

                                      if (_loadingInputs)
                                        const Center(
                                          child:
                                              CircularProgressIndicator(),
                                        )
                                      else
                                        ..._topicInputs.map(
                                          _buildTopicInput,
                                        ),

                                      if (!_loadingInputs)
                                        SizedBox(
                                          width:
                                              double.infinity,
                                          height: 44,
                                          child:
                                              ElevatedButton(
                                            style:
                                                ElevatedButton
                                                    .styleFrom(
                                              backgroundColor:
                                                  const Color(
                                                0xFFFF6600,
                                              ),
                                              elevation: 0,
                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                  8,
                                                ),
                                              ),
                                            ),
                                            onPressed:
                                                _loadingResponse
                                                    ? null
                                                    : _submitTopic,
                                            child:
                                                _loadingResponse
                                                    ? const SizedBox(
                                                        width:
                                                            20,
                                                        height:
                                                            20,
                                                        child:
                                                            CircularProgressIndicator(
                                                          strokeWidth:
                                                              2,
                                                          color: Colors
                                                              .white,
                                                        ),
                                                      )
                                                    : const Text(
                                                        'Ask Meroguru',
                                                        style:
                                                            TextStyle(
                                                          color: Colors
                                                              .white,
                                                          fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                          fontSize:
                                                              14,
                                                        ),
                                                      ),
                                          ),
                                        ),

                                      if (_guruResponse !=
                                          null) ...[
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          width:
                                              double.infinity,
                                          padding:
                                              const EdgeInsets
                                                  .all(16),
                                          decoration:
                                              BoxDecoration(
                                            color:
                                                const Color(
                                              0xFFFFF4EC,
                                            ),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(8),
                                            border:
                                                Border.all(
                                              color:
                                                  const Color(
                                                0xFFFF6600,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            _guruResponse!,
                                            style:
                                                const TextStyle(
                                              fontSize: 14,
                                              color: Colors
                                                  .black87,
                                              height: 1.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }
}