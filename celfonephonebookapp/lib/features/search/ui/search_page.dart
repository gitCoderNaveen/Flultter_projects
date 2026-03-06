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

  SearchFilter _filter = SearchFilter.business;

  bool _loading = false;
  List<dynamic> _results = [];

  bool _initialized = false;

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

  /// SEARCH BARS UI
  Widget _buildSearchBars() {
    final isBusiness = _filter == SearchFilter.business;

    return Row(
      children: [
        /// BUSINESS SEARCH
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
                });
              },

              onChanged: (value) {
                setState(() {
                  _filter = SearchFilter.business;
                });

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

        /// PRODUCT SEARCH
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
                });
              },

              onChanged: (value) {
                setState(() {
                  _filter = SearchFilter.products;
                });

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
