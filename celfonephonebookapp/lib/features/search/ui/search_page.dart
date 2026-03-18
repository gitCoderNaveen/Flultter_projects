import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  bool _loading = false;
  List<dynamic> _results = [];

  bool _initialized = false;
  String _sortOption = 'date_desc';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final uri = GoRouterState.of(context).uri;
    final params = uri.queryParameters;

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

    _fetchDefault();
  }

  /// default fetch
  Future<void> _fetchDefault() async {
    setState(() => _loading = true);

    final res = await supabase
        .from('profiles')
        .select()
        .order('created_at', ascending: false);

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

    final res = await supabase
        .from('profiles')
        .select()
        .ilike('city', '%$city%') // 👈 adjust column name if needed
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
    if (query.trim().isEmpty) {
      _fetchDefault();
      return;
    }

    if (query.length < 2) return;

    setState(() => _loading = true);

    String condition;

    if (_filter == SearchFilter.business) {
      condition = 'business_name.ilike.%$query%,person_name.ilike.%$query%';
    } else {
      condition = 'keywords.ilike.%$query%';
    }

    final res = await supabase
        .from('profiles')
        .select()
        .or(condition)
        .order('is_prime', ascending: false)
        .order('priority', ascending: false)
        .order('normal_list', ascending: false)
        .order('is_business', ascending: false);

    setState(() {
      _results = res;
      _loading = false;
    });

    _logSearch(query, _filter.name);
  }

  Future<void> _searchByLetter(String letter) async {
    setState(() => _loading = true);

    final res = await supabase
        .from('profiles')
        .select()
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

    dynamic query = supabase.from('profiles').select();

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
      return Row(
        children: [
          /// 🔙 BACK BUTTON
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _filter = SearchFilter.business; // default mode
                _cityController.clear();
              });

              if (_businessController.text.isNotEmpty) {
                _search(_businessController.text);
              } else if (_productController.text.isNotEmpty) {
                _search(_productController.text);
              } else {
                _fetchDefault();
              } // reload default data
            },
          ),

          /// CITY SEARCH FIELD
          Expanded(
            child: TextField(
              controller: _cityController,

              onChanged: (value) {
                _searchByCity(value);
              },

              decoration: InputDecoration(
                hintText: "Search by City",
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final isBusiness = _filter == SearchFilter.business;

    return Row(
      children: [
        // BUSINESS (same as before)
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

        // PRODUCT (same as before)
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

        const SizedBox(width: 8),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          color: const Color.fromARGB(255, 255, 255, 255),
          onSelected: (value) {
            if (value == 'city') {
              setState(() {
                _filter = SearchFilter.city;

                // clear other fields
                _businessController.clear();
                _productController.clear();
              });
              return;
            }

            setState(() {
              _sortOption = value;
            });

            _fetchSortedData();
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'az', child: Text('A → Z', style: TextStyle(fontSize: 14),)),
            const PopupMenuItem(value: 'za', child: Text('Z → A',style: TextStyle(fontSize: 14),)),
            const PopupMenuItem(
              value: 'date_asc',
              child: Text('Date Ascending', style: TextStyle(fontSize: 14),),
            ),
            const PopupMenuItem(
              value: 'date_desc',
              child: Text('Date Descending',style: TextStyle(fontSize: 14),),
            ),
            const PopupMenuItem(
              value: 'city',
              child: Text('Search by City',style: TextStyle(fontSize: 14),),
            ), // 👈 NEW
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
