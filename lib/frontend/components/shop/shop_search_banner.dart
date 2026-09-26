import 'package:flutter/material.dart';

class ShopSearchBanner extends StatefulWidget {
  const ShopSearchBanner({
    super.key,
    required this.onSearch,
  });

  final Future<void> Function(String query) onSearch;

  @override
  State<ShopSearchBanner> createState() =>
      _ShopSearchBannerState();
}

class _ShopSearchBannerState
    extends State<ShopSearchBanner> {
  final TextEditingController _searchController =
      TextEditingController();

  bool _searching = false;
  String _lastSubmittedQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submitSearch() async {
  if (_searching) return;

  final query =
      _searchController.text.trim();

  // Prevent repeating the same search.
  if (query == _lastSubmittedQuery) {
    return;
  }

  FocusScope.of(context).unfocus();

  setState(() {
    _searching = true;
  });

  try {
    await widget.onSearch(query);

    _lastSubmittedQuery = query;
  } finally {
    if (mounted) {
      setState(() {
        _searching = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submitSearch(),
            decoration: InputDecoration(
              hintText: 'Search products',
              prefixIcon: const Icon(
                Icons.search,
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            widget.onSearch('');
                          },
                          icon: const Icon(
                            Icons.close,
                          ),
                        )
                      : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFFFF5A00),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed:
                _searching ? null : _submitSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFFF5A00),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10),
              ),
            ),
            child: _searching
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.3,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Search',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}