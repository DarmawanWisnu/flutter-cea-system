import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fountaine/providers/provider/api_provider.dart';

final apiKitsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) async {
  final api = ref.watch(apiServiceProvider);

  final res = await api.getJson('/kits/with-latest');

  if (res is! List) return [];

  return res.map<Map<String, dynamic>>((e) {
    if (e is Map) {
      return Map<String, dynamic>.from(e);
    }
    return <String, dynamic>{};
  }).toList();
});
