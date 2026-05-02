import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../app/theme.dart';

class ColonyListScreen extends StatefulWidget {
  const ColonyListScreen({super.key});

  @override
  State<ColonyListScreen> createState() => _ColonyListScreenState();
}

class _ColonyListScreenState extends State<ColonyListScreen> {
  List<dynamic> _colonies = [];
  bool _loading = true;
  String _search = '';
  int _page = 0;
  bool _hasMore = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadColonies();
  }

  Future<void> _loadColonies({bool reset = false}) async {
    if (reset) { _page = 0; _hasMore = true; }
    setState(() => _loading = true);
    try {
      final data = await apiService.getColonies(
        page: _page, size: 10,
        location: _search.isEmpty ? null : _search,
      );
      final content = data['content'] as List;
      setState(() {
        if (reset) _colonies = content;
        else _colonies.addAll(content);
        _hasMore = !(data['last'] as bool? ?? true);
        _page++;
      });
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by location...',
              prefixIcon: const Icon(Icons.search, color: MelariumTheme.honey500),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                      _searchCtrl.clear();
                      setState(() => _search = '');
                      _loadColonies(reset: true);
                    })
                  : null,
            ),
            onChanged: (v) {
              setState(() => _search = v);
              _loadColonies(reset: true);
            },
          ),
        ),

        Expanded(
          child: _loading && _colonies.isEmpty
              ? const Center(child: CircularProgressIndicator(color: MelariumTheme.honey500))
              : _colonies.isEmpty
                  ? const Center(child: Text('No colonies found 🐝', style: TextStyle(color: Colors.white54)))
                  : RefreshIndicator(
                      color: MelariumTheme.honey500,
                      onRefresh: () => _loadColonies(reset: true),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: _colonies.length + (_hasMore ? 1 : 0),
                        itemBuilder: (ctx, i) {
                          if (i == _colonies.length) {
                            return TextButton(
                              onPressed: _loadColonies,
                              child: const Text('Load more', style: TextStyle(color: MelariumTheme.honey400)),
                            );
                          }
                          return _ColonyTile(colony: _colonies[i]);
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

class _ColonyTile extends StatelessWidget {
  final Map<String, dynamic> colony;
  const _ColonyTile({required this.colony});

  @override
  Widget build(BuildContext context) {
    final soldPct = colony['totalShares'] > 0
        ? ((colony['totalShares'] - colony['availableShares']) / colony['totalShares'] * 100).round()
        : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.go('/colony/${colony['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🐝', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(colony['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 12, color: Colors.white38),
                            const SizedBox(width: 2),
                            Text(colony['location'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (colony['isVerified'] == true)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: MelariumTheme.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: MelariumTheme.success.withOpacity(0.3)),
                      ),
                      child: const Text('✓', style: TextStyle(fontSize: 11, color: MelariumTheme.success)),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Stats row
              Row(
                children: [
                  _stat('\$${colony['pricePerShare']}', 'per share'),
                  const SizedBox(width: 16),
                  _stat('${colony['expectedRoiPct']}%', 'ROI', color: MelariumTheme.success),
                  const SizedBox(width: 16),
                  _stat('${colony['availableShares']}', 'available'),
                ],
              ),

              const SizedBox(height: 12),
              // Progress
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: soldPct / 100,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(MelariumTheme.honey500),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Text('$soldPct% sold', style: const TextStyle(fontSize: 11, color: Colors.white38)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String value, String label, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: color ?? MelariumTheme.honey400)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38)),
      ],
    );
  }
}
