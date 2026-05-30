import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';

import '../model/search_filter.dart';
import '../ui/search_result_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final supabase = Supabase.instance.client;

  final _businessController = TextEditingController();
  final _productController = TextEditingController();
  final _cityController = TextEditingController();

  SearchFilter _filter = SearchFilter.business;

  SearchFilter searchQuery = SearchFilter.business;

  SearchFilter _citySearchType = SearchFilter.business;

  bool _loading = false;
  List<dynamic> _results = [];
  List<String> _cities = [];
  String? _selectedCity;

  String? _currentExpoId; // Expo ID filter
  bool _initialized = false;
  String _sortOption = 'date_desc';

  /// Apply expo_id filter if available
  PostgrestFilterBuilder _applyExpoFilter(dynamic query) {
    if (_currentExpoId != null) {
      return query.eq('expo_id', _currentExpoId!);
    }
    return query;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final uri = GoRouterState.of(context).uri;
    final params = uri.queryParameters;

    // Always capture expo_id if present (for all search types)
    _currentExpoId = params['expo_id'];

    if (params.containsKey('service')) {
      _productController.text = params['service']!;
      _filter = SearchFilter.products;
      _search(params['service']!);
      return;
    }

    if (params.containsKey('letter')) {
      _searchByLetter(params['letter']!);
      return;
    }
    if (params.containsKey('city')) {
      final city = params['city']!;

      _fetchCities().then((_) {
        setState(() {
          _selectedCity = city;
          _filter = SearchFilter.city;
        });

        _searchByCity(city);
      });

      return;
    }
    if (params.containsKey('expo_id')) {
      _searchByExpo(params['expo_id']!);
      return;
    }

    _fetchDefault();
  }

  Future<void> _searchByExpo(String expoId) async {
    setState(() {
      _currentExpoId = expoId;
      _loading = true;
    });

    final res =
        await _applyExpoFilter(
              supabase.from('profiles').select('*, expo:expo_id(expo_edition)'),
            )
            .order('is_prime', ascending: false)
            .order('priority', ascending: false)
            .order('normal_list', ascending: false)
            .order('is_business', ascending: false);

    setState(() {
      _results = res;
      _loading = false;
    });
  }

  Future<void> _fetchCities() async {
    final res = await _applyExpoFilter(
      supabase.from('profiles').select('city'),
    );

    final citySet = <String>{};

    for (var item in res) {
      if (item['city'] != null && item['city'].toString().trim().isNotEmpty) {
        citySet.add(item['city']);
      }
    }

    setState(() {
      _cities = citySet.toList()..sort();
    });
  }

  /// default fetch
  Future<void> _fetchDefault() async {
    setState(() => _loading = true);

    final res = await _applyExpoFilter(
      supabase.from('profiles').select('*, expo:expo_id(expo_edition)'),
    ).order('created_at', ascending: false);

    setState(() {
      _results = res;
      _loading = false;
    });
  }

  Future<void> _searchByCity(String city) async {
    if (city.trim().isEmpty) {
      _fetchDefault();
      return;
    }

    setState(() => _loading = true);

    final res =
        await _applyExpoFilter(
              supabase.from('profiles').select('*, expo:expo_id(expo_edition)'),
            )
            .ilike('city', '%$city%')
            .order('is_prime', ascending: false)
            .order('priority', ascending: false)
            .order('normal_list', ascending: false)
            .order('is_business', ascending: false);

    setState(() {
      _results = res;
      _loading = false;
    });
  }

  /// search
  Future<void> _search(String query) async {
    if (_filter == SearchFilter.city && _selectedCity == null) return;

    if (query.trim().isEmpty) {
      if (_filter == SearchFilter.city && _selectedCity != null) {
        // city selected + keyword clear pannina = city results matum (expo filter udane)
        _searchByCity(_selectedCity!);
      } else {
        _fetchDefault();
      }
      return;
    }

    if (query.length < 2) return;

    setState(() => _loading = true);

    final activeFilter = _filter == SearchFilter.city
        ? _citySearchType
        : _filter;

    var queryBuilder = supabase
        .from('profiles')
        .select('*, expo:expo_id(expo_edition)');

    // Step 1: expo_id hard filter (must be before .or() to avoid bypass)
    if (_currentExpoId != null) {
      queryBuilder = queryBuilder.eq('expo_id', _currentExpoId!);
    }

    // Step 2: city filter
    if (_filter == SearchFilter.city && _selectedCity != null) {
      queryBuilder = queryBuilder.ilike('city', '%$_selectedCity%');
    }

    // Step 3: business or product/keywords search
    if (activeFilter == SearchFilter.business) {
      queryBuilder = queryBuilder.or(
        'business_name.ilike.%$query%,person_name.ilike.%$query%',
      );
    } else {
      queryBuilder = queryBuilder.ilike('keywords', '%$query%');
    }

    final res = await queryBuilder
        .order('is_prime', ascending: false)
        .order('priority', ascending: false)
        .order('normal_list', ascending: false)
        .order('is_business', ascending: false);

    setState(() {
      _results = res;
      _loading = false;
    });

    _logSearch(query, activeFilter.name);
  }

  Future<void> _searchByLetter(String letter) async {
    setState(() => _loading = true);

    final res =
        await _applyExpoFilter(
              supabase.from('profiles').select('*, expo:expo_id(expo_edition)'),
            )
            .ilike('business_name', '${letter.toUpperCase()}%')
            .order('is_prime', ascending: false)
            .order('priority', ascending: false)
            .order('normal_list', ascending: false)
            .order('is_business', ascending: false);

    setState(() {
      _results = res;
      _loading = false;
    });
  }

  Future<void> _logSearch(String query, String filter) async {
    final user = supabase.auth.currentUser;

    if (user == null) return;

    await supabase.from('search_logs').insert({
      'user_id': user.id,
      'query': query,
      'filter': filter,
    });
  }

  Future<void> _fetchSortedData() async {
    setState(() => _loading = true);

    dynamic query = _applyExpoFilter(supabase.from('profiles').select());

    switch (_sortOption) {
      case 'az':
        query = query.order('display_name', ascending: true);
        break;

      case 'za':
        query = query.order('display_name', ascending: false);
        break;

      case 'date_asc':
        query = query.order('created_at', ascending: true);
        break;

      case 'date_desc':
        query = query.order('created_at', ascending: false);
        break;
    }

    final res = await query;

    setState(() {
      _results = res;
      _loading = false;
    });
  }

  /// SEARCH BARS UI
  Widget _buildSearchBars() {
    if (_filter == SearchFilter.city) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 BEFORE CITY SELECTED → show dropdown
          if (_selectedCity == null) ...[
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _filter = SearchFilter.business;
                    });
                    _fetchDefault();
                  },
                ),

                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCity,
                    hint: const Text("Select City"),
                    items: _cities.map((city) {
                      return DropdownMenuItem(value: city, child: Text(city));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                      });
                      _searchByCity(value!);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          /// 🔹 AFTER CITY SELECTED → compact row
          if (_selectedCity != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 ROW 1 → CITY TAG
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _selectedCity!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCity = null;
                              });
                              _fetchDefault();
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.close, size: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// 🔹 ROW 2 → SEARCH FIELDS
                Row(
                  children: [
                    /// BUSINESS SEARCH
                    Expanded(
                      flex: _citySearchType == SearchFilter.business ? 8 : 2,
                      child: TextField(
                        controller: _businessController,
                        onTap: () {
                          setState(() {
                            _citySearchType = SearchFilter.business;
                            _productController.clear();
                          });
                        },
                        onChanged: _search,
                        decoration: InputDecoration(
                          hintText: "Business",
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /// PRODUCT SEARCH
                    Expanded(
                      flex: _citySearchType == SearchFilter.products ? 8 : 2,
                      child: TextField(
                        controller: _productController,
                        onTap: () {
                          setState(() {
                            _citySearchType = SearchFilter.products;
                            _businessController.clear();
                          });
                        },
                        onChanged: _search,
                        decoration: InputDecoration(
                          hintText: "Product search",
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      );
    }

    final isBusiness = _filter == SearchFilter.business;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔥 NEW: SEARCH CITY BUTTON (TOP)
        GestureDetector(
          onTap: () {
            setState(() {
              _filter = SearchFilter.city;
              _businessController.clear();
              _productController.clear();
              _selectedCity = null;
            });

            _fetchCities(); // load cities
          },
          child: Row(
            children: const [
              Icon(Icons.location_on, color: Colors.red),
              SizedBox(width: 6),
              Text(
                "Search city",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        /// 🔻 EXISTING SEARCH BARS (UNCHANGED)
        Row(
          children: [
            Expanded(
              flex: isBusiness ? 8 : 2,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 45,
                child: TextField(
                  controller: _businessController,
                  onTap: () {
                    setState(() {
                      _filter = SearchFilter.business;
                      _productController.clear();
                    });
                  },
                  onChanged: (value) {
                    _search(value);
                  },
                  decoration: InputDecoration(
                    hintText: "Business search",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              flex: isBusiness ? 2 : 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 45,
                child: TextField(
                  controller: _productController,
                  onTap: () {
                    setState(() {
                      _filter = SearchFilter.products;
                      _businessController.clear();
                    });
                  },
                  onChanged: (value) {
                    _search(value);
                  },
                  decoration: InputDecoration(
                    hintText: "Product search",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const _HeaderRow(collapsed: true)),

      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16), child: _buildSearchBars()),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? const Center(child: Text("No results"))
                : ListView.builder(
                    itemCount: _results.length,

                    itemBuilder: (_, i) {
                      return SearchResultCard(
                        item: _results[i],
                        filter: _filter,
                        searchQuery: _filter == SearchFilter.business
                            ? _businessController.text
                            : '',
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final bool collapsed;
  const _HeaderRow({required this.collapsed});

  @override
  Widget build(BuildContext context) {
    final color = collapsed ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: "Cel",
                            style: TextStyle(color: Colors.red),
                          ),
                          TextSpan(
                            text: "fon",
                            style: TextStyle(color: Colors.blue),
                          ),
                          TextSpan(
                            text: " Book",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Text(
                    "Connects For Growth",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
