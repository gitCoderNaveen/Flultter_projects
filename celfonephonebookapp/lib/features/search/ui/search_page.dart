import 'package:celfonephonebookapp/core/constants/db_tables.dart';
import 'package:celfonephonebookapp/features/search/ui/search_result_card.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/search_filter.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final supabase = Supabase.instance.client;

  bool _loading = false;
  List<dynamic> _results = [];

  SearchFilter _filter = SearchFilter.business;

  @override
  void initState() {
    super.initState();
    _fetchAllDefault();
  }

  // 🔹 Default fetch
  Future<void> _fetchAllDefault() async {
    setState(() => _loading = true);

    final res = await supabase
        .from(DbTables.profiles)
        .select()
        .order('is_prime', ascending: false)
        .order('priority', ascending: false);

    setState(() {
      _results = res;
      _loading = false;
    });
  }

  Future<void> logSearch({
    required String query,
    required String filter,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('search_logs').insert({
      'user_id': user.id,
      'query': query,
      'filter': filter, // business / product / city
    });
  }

  // 🔍 Filtered search
  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _fetchAllDefault();
      return;
    }

    if (query.length < 2) return;

    setState(() => _loading = true);

    String condition;

    switch (_filter) {
      case SearchFilter.business:
        condition = 'business_name.ilike.%$query%,person_name.ilike.%$query%';
        break;
      case SearchFilter.products:
        condition = 'keywords.ilike.%$query%';
        break;
    }

    final res = await supabase
        .from('profiles')
        .select()
        .or(condition)
        .order('is_prime', ascending: false)
        .order('priority', ascending: false);

    setState(() {
      _results = res;
      _loading = false;
    });
    logSearch(query: query, filter: _filter.name);
  }

  // search log

  // 🔹 Filter Picker
  void _showFilterPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: SearchFilter.values.map((f) {
          return ListTile(
            title: Text(f.label),
            trailing: f == _filter
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () {
              setState(() => _filter = f);
              Navigator.pop(context);
              _search(_controller.text);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _search,
                    decoration: InputDecoration(
                      hintText: 'Search ${_filter.label}',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterPicker,
                ),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                ? const Center(child: Text('No results found'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (_, i) => SearchResultCard(
                      item: _results[i],
                      filter: _filter, // 👈 pass selected filter
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
